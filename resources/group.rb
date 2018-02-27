property :group_name, String, name_property: true
property :group_type, String, regex: /-group$/, default: 'maven2-group'
property :repositories, Array, default: lazy { [] }
property :attributes, Hash, default: lazy { ::Mash.new } # Not mandatory but strongly recommended in the generic case.
property :online, [true, false], default: true
property :api_endpoint, String, identity: true, default: lazy { node['nexus3']['api']['endpoint'] }
property :api_username, String, identity: true, default: lazy { node['nexus3']['api']['username'] }
property :api_password, String, identity: true, sensitive: true,
                                default: lazy { node['nexus3']['api']['password'] }

action :create do
  nexus3_repo new_resource.group_name do
    action :create

    repo_type new_resource.group_type
    online new_resource.online
    attributes new_resource.attributes.merge(group: { memberNames: new_resource.repositories })

    api_endpoint new_resource.api_endpoint
    api_username new_resource.api_username
    api_password new_resource.api_password
  end
end

action :delete do
  nexus3_repo new_resource.group_name do
    action :delete

    api_endpoint new_resource.api_endpoint
    api_username new_resource.api_username
    api_password new_resource.api_password
  end
end
