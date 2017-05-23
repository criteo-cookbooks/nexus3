property :repo_name, String, name_attribute: true
property :repo_type, String, default: 'maven2-hosted'.freeze
property :attributes, Hash, default: lazy { Mash.new } # Not mandatory but strongly recommended in the generic case.
property :online, [true, false], default: true
property :api_url, String, desired_state: false, identity: true, default: 'http://localhost:8081/service/siesta/rest/v1/script/'.freeze
property :api_user, String, desired_state: false, identity: true, default: 'admin'.freeze
property :api_password, String, desired_state: false, identity: true, default: 'admin123'.freeze

def apiclient
  @apiclient ||= ::Nexus3::Api.new(api_url, api_user, api_password)
end

load_current_value do |desired|
  api_url desired.api_url
  api_user desired.api_user
  api_password desired.api_password

  begin
    config = JSON.parse(apiclient.run_script('get_repo', desired.repo_name))
    ::Chef::Log.warn "Config is: #{config}"
    repo_name config['repositoryName']
    repo_type config['recipeName']
    attributes config['attributes']
    online config['online']
  # We rescue here because during the first run, the repository will not exist yet, so we let Chef know that
  # the resource has to be created.
  rescue LoadError, StandardError => e
    ::Chef::Log.warn "A '#{e.class}' occured: #{e.message}"
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
      args name: new_resource.repo_name,
           type: new_resource.repo_type,
           online: new_resource.online,
           attributes: new_resource.attributes

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
 if (conf.getRecipeName() != params.type) {
    throw new Exception("Tried to change recipe for repo ${params.name} to ${params.type}")
  }
  conf.setOnline(params.online)
  conf.setAttributes(params.attributes)
  repo.stop()
  repo.update(conf)
  repo.start()
}

  true
    EOS
    end
  end
end

action :delete do
  chef_gem 'httpclient'

  nexus3_api 'delete_repo' do
    action %i(create run)
    content <<-EOS
def repo = repository.repositoryManager.get(args)
if (repo != null) {
  repository.repositoryManager.delete(args)
}
    EOS
    args new_resource.repo_name

    endpoint new_resource.api_url
    username new_resource.api_user
    password new_resource.api_password
  end
end

action_class.class_eval do
  def whyrun_supported?
    true
  end
end
