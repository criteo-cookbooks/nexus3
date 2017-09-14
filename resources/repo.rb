property :repo_name, String, desired_state: false, identity: true, name_attribute: true
property :repo_type, String, desired_state: false, identity: true, default: 'maven2-hosted'.freeze
property :attributes, Hash, default: lazy { ::Mash.new } # Not mandatory but strongly recommended in the generic case.
property :online, [true, false], default: true
property :api_url, String, desired_state: false, identity: true, default: 'http://localhost:8081/service/siesta/rest/v1/script/'.freeze
property :api_user, String, desired_state: false, identity: true, default: 'admin'.freeze
property :api_password, String, desired_state: false, identity: true, sensitive: true, default: 'admin123'.freeze

def apiclient
  @apiclient ||= ::Nexus3::Api.new(api_url, api_user, api_password)
end

load_current_value do |desired|
  api_url desired.api_url
  api_user desired.api_user
  api_password desired.api_password

  begin
    res = apiclient.run_script('get_repo', desired.repo_name)
    current_value_does_not_exist! if res == 'null'
    config = JSON.parse(res)
    ::Chef::Log.warn "Config is: #{config}"
    repo_name config['repositoryName']
    repo_type config['recipeName']
    attributes config['attributes']
    online config['online']
  # We rescue here because during the first run, the repository will not exist yet, so we let Chef know that
  # the resource has to be created.
  rescue LoadError, ::Nexus3::ApiError => e
    ::Chef::Log.warn "A '#{e.class}' occured: #{e.message}"
    current_value_does_not_exist!
  end
end

action :create do
  init

  converge_if_changed do
    nexus3_api "upsert_repo #{new_resource.repo_name}" do
      script_name 'upsert_repo'
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
  init

  nexus3_api "delete_repo #{new_resource.repo_name}" do
    action %i(create run)
    script_name 'delete_repo'
    content <<-EOS
def repo = repository.repositoryManager.get(args)
if (repo == null) {
   return false
}
repository.repositoryManager.delete(args)
true
    EOS
    args new_resource.repo_name

    endpoint new_resource.api_url
    username new_resource.api_user
    password new_resource.api_password

    not_if { current_resource.nil? }
  end
end

action_class.class_eval do
  def init
    chef_gem 'httpclient' do
      compile_time true
    end

    nexus3_api "get_repo #{new_resource.repo_name}" do
      action :create
      script_name 'get_repo'
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
  end

  def whyrun_supported?
    true
  end
end
