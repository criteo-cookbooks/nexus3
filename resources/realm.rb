property :name, String, name_property: true
property :api_client, ::Nexus3::Api, identity: true, default: lazy { ::Nexus3::Api.default(node) }

action :enable do
  init

  nexus3_api "enable #{new_resource.name}" do
    script_name 'realm'
    args name: new_resource.name,
         action: 'enable'

    action %i(create run)
    api_client new_resource.api_client

    content ::Nexus3::Scripts.groovy_content('realm', node)
  end
end

action :disbale do
  init

  nexus3_api "disable #{new_resource.name}" do
    script_name 'realm'
    args name: new_resource.name,
         action: 'disable'

    action %i(create run)
    api_client new_resource.api_client

    content ::Nexus3::Scripts.groovy_content('realm', node)
  end
end

action_class do
  def whyrun_supported?
    true
  end
end
