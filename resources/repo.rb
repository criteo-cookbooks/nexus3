property :repo_name, String, name_attribute: true
property :repo_type, String, default: 'maven-hosted'
property :attributes, Hash, default: lazy { Mash.new } # Not mandatory but strongly recommended in the generic case.
property :online, [true, false], default: true
property :api_url, String, required: true, identity: true
property :api_user, String, required: true, identity: true
property :api_password, String, required: true, identity: true

def textify(args)
  require 'json'
  JSON.generate(args)
end

def apiclient
  @apiclient ||= ::Nexus3::Api.new(api_url, api_user, api_password)
end

load_current_value do |desired|
  api_url desired.api_url
  api_user desired.api_user
  api_password desired.api_password

  begin
    config = apiclient.run_script('get_repo', desired.repo_name)
    repo_name config['repositoryName']
    repo_type config['recipeName']
    attributes attributes.merge(config['attributes'])
    online config['online']
  # We rescue here because during the first run, the repository will not exist yet, so we let Chef know that
  # the resource has to be created.
  rescue LoadError, StandardError
    current_value_does_not_exist!
  end
end

action :create do
  chef_gem 'httpclient'

  nexus3_api 'get_repo' do
    action :create
    endpoint new_resource.api_url
    username new_resource.api_user
    password new_resource.api_password

    content <<-EOS
import groovy.json.JsonOutput
conf = repository.repositoryManager.get(args)?.getConfiguration()
if (conf != null) {
  JsonOutput.toJson([
    repositoryName: conf.getRepositoryName(),
    recipeName: conf.getRecipeName(),
    online: conf.isOnline(),
    attributes: conf.getAttributes()
  ])
}
    EOS
  end

  converge_if_changed do
    nexus3_api 'upsert_repo' do
      # TODO: Current nexus3_api passes a string and text/plain, change this back to a Hash later
      args textify(name: new_resource.repo_name,
                   type: new_resource.repo_type,
                   online: new_resource.online,
                   attributes: new_resource.attributes)
      action %i(create run)
      endpoint new_resource.api_url
      username new_resource.api_user
      password new_resource.api_password

      content <<-EOS
import groovy.json.JsonSlurper
import groovy.json.JsonOutput

import org.sonatype.nexus.repository.config.Configuration

def params = new JsonSlurper().parseText(args)

def repo = repository.repositoryManager.get(params.name)
Configuration conf
if (repo == null) { // create
  conf = new Configuration(
    repositoryName: params.name,
    recipeName: params.type,
    online: params.online,
    attributes: params.attributes
  )
  repository.createRepository(conf)
  } else { // update
    conf = repo.getConfiguration()
    if (conf.getRepositoryName() != params.name) {
      log.warn('Tried to change the repository name to ${params.name}')
    }
    if (conf.getRecipeName() != params.type) {
      // TODO: throw an exception
      log.warn('Tried to change recipe for repo ${params.name} to ${params.type}')
    }
    conf.setOnline(params.online)
    conf.setAttributes(params.attributes)
    repo.update(conf)
  }

  true
    EOS
    end
  end
end

action :delete do
  chef_gem 'httpclient'

  nexus3_api 'delete_repo' do
    action :create, :run
    endpoint new_resource.api_url
    username new_resource.api_user
    password new_resource.api_password
    args new_resource.repo_name

    content 'repository.repositoryManager.delete(args)'
  end
end

action_class.class_eval do
  def whyrun_supported?
    true
  end
end
