property :repo_name, String, name_property: true
property :repo_type, String, default: 'maven2-hosted'
property :attributes, Hash, default: lazy { ::Mash.new } # Not mandatory but strongly recommended in the generic case.
property :online, [true, false], default: true
property :api_client, ::Nexus3::Api, identity: true, default: lazy { ::Nexus3::Api.default(node) }

load_current_value do |desired|
  begin
    config = ::JSON.parse(api_client.run_script('get_repo', desired.repo_name))
    current_value_does_not_exist! if config.nil?
    ::Chef::Log.debug "Config is: #{config}"
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
      api_client new_resource.api_client

      content ::Nexus3::Scripts.groovy_content('upsert_repo', node)
    end
  end
end

action :delete do
  init

  nexus3_api "delete_repo #{new_resource.repo_name}" do
    action %i(create run)
    script_name 'delete_repo'
    content ::Nexus3::Scripts.groovy_content('delete_repo', node)
    args new_resource.repo_name

    api_client new_resource.api_client

    not_if { current_resource.nil? }
  end
end

action_class do
  def init
    chef_gem 'httpclient' do
      compile_time true
    end

    nexus3_api "get_repo #{new_resource.repo_name}" do
      action :create
      script_name 'get_repo'
      api_client new_resource.api_client

      content ::Nexus3::Scripts.groovy_content('get_repo', node)
    end
  end
end
