actions :install, :uninstall
default_action :install

attribute :servicename, kind_of: String, name_attribute: true
attribute :user, kind_of: [String, NilClass]
attribute :group, kind_of: [String, NilClass]
attribute :password, kind_of: [String, NilClass]
attribute :url, kind_of: String, default: lazy { node['nexus3']['url'] }
attribute :checksum, kind_of: String, default: lazy { node['nexus3']['checksum'] }
attribute :path, kind_of: String, default: lazy { node['nexus3']['path'] }
attribute :data, kind_of: String, default: lazy { node['nexus3']['data'] }
attribute :home, kind_of: String, default: lazy { node['nexus3']['home'] }
attribute :properties_cookbook, kind_of: String, default: lazy { node['nexus3']['properties_cookbook'] }
attribute :properties_source, kind_of: String, default: lazy { node['nexus3']['properties_source'] }
attribute :properties_variables, kind_of: Hash, default: lazy { node['nexus3']['properties_variables'] }
attribute :vmoptions_cookbook, kind_of: String, default: lazy { node['nexus3']['vmoptions_cookbook'] }
attribute :vmoptions_source, kind_of: String, default: lazy { node['nexus3']['vmoptions_source'] }
attribute :vmoptions_variables, kind_of: Hash, default: lazy { node['nexus3']['vmoptions_variables'] }
