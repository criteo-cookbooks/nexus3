actions :run, :upload, :delete, :list
default_action :run

attribute :script_name, kind_of: String, name_attribute: true
attribute :username, kind_of: String, default: 'admin'
attribute :password, kind_of: String, default: 'admin123'
attribute :content, kind_of: [String, NilClass]
attribute :cookbook_name, kind_of: String, default: lazy { node['nexus3']['api']['cookbook_name'] }
attribute :cookbook_source, kind_of: [String, NilClass]
attribute :args, kind_of: [Array, NilClass]
attribute :type, kind_of: String, default: lazy { node['nexus3']['api']['type'] }
attribute :endpoint, kind_of: String, default: lazy { node['nexus3']['api']['endpoint'] }
attribute :fail, kind_of: [TrueClass, FalseClass], default: lazy { node['nexus3']['api']['fail'] }
attribute :live_stream, kind_of: [TrueClass, FalseClass], default: lazy { node['nexus3']['api']['live_stream'] }
attribute :sensitive, kind_of: [TrueClass, FalseClass] # , default: true - see initialize below

# Chef will override sensitive back to its global value, so set default to true in init
def initialize(*args)
  super
  @sensitive = lazy { node['nexus3']['api']['sensitive'] }
end
