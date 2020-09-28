property :realm_name, String, name_property: true
property :enable, [true, false], required: true
property :api_client, ::Nexus3::Api, identity: true, default: lazy { ::Nexus3::Api.default(node) }

load_current_value do |desired|
  # By default, it will be 'false' if given realm not exist on server's side, then
  # only two possible results will be returned: 'true' or 'false'
  begin
    enabled = api_client.run_script('get_realm_status', desired.realm_name)
    ::Chef::Log.debug "Current status is: #{enabled}"
    enable enabled == 'true'
  rescue ::LoadError, ::Nexus3::ApiError => e
    ::Chef::Log.warn "A '#{e.class}' occurred: #{e.message}"
    current_value_does_not_exist!
  end
end

action :configure do
  init

  converge_if_changed do
    nexus3_api "configure #{new_resource.realm_name}" do
      script_name 'configure_realm'
      args name: new_resource.realm_name,
           enable: new_resource.enable

      action %i[create run]
      api_client new_resource.api_client

      content ::Nexus3::Scripts.groovy_content('configure_realm', node)
    end
  end
end

action_class do
  def init
    nexus3_api "get_realm_status #{new_resource.realm_name}" do
      action :create
      script_name 'get_realm_status'
      args new_resource.realm_name
      api_client new_resource.api_client

      content ::Nexus3::Scripts.groovy_content('get_realm_status', node)
    end
  end

  def whyrun_supported?
    true
  end
end
