property :group_name, String, name_property: true
property :group_type, String, regex: /-group$/, default: 'maven2-group'
property :repositories, Array, default: lazy { [] }
property :attributes, Hash, default: lazy { ::Mash.new } # Not mandatory but strongly recommended in the generic case.
property :online, [true, false], default: true
property :api_client, ::Nexus3::Api, identity: true, default: lazy { ::Nexus3::Api.default(node) }

action :create do
  nexus3_repo new_resource.group_name do
    action :create

    repo_type new_resource.group_type
    online new_resource.online
    attributes new_resource.attributes.merge(group: { memberNames: new_resource.repositories })

    api_client new_resource.api_client
  end
end

action :delete do
  nexus3_repo new_resource.group_name do
    action :delete

    api_client new_resource.api_client
  end
end
