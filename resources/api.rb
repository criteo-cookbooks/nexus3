actions :run, :create, :delete, :list
default_action :run

attribute :script_name, kind_of: String, name_attribute: true
attribute :username, kind_of: String, default: 'admin'
attribute :password, kind_of: String, default: 'admin123'
attribute :content, kind_of: [String, NilClass]
attribute :script_cookbook, kind_of: String
attribute :script_source, kind_of: [String, NilClass]
attribute :args, kind_of: [Array, String, NilClass]
attribute :type, kind_of: String
attribute :host, kind_of: String
attribute :endpoint, kind_of: String
attribute :ignore_failure, kind_of: [TrueClass, FalseClass]
attribute :live_stream, kind_of: [TrueClass, FalseClass]
attribute :wait, kind_of: Integer
attribute :sensitive, kind_of: [TrueClass, FalseClass] # , default: true - see initialize below

def initialize(*args)
  super
  @script_cookbook = lazy { node['nexus3']['api']['script_cookbook'] }
  @type = lazy { node['nexus3']['api']['type'] }
  @host = lazy { node['nexus3']['api']['host'] }
  @endpoint = lazy { node['nexus3']['api']['endpoint'] }
  @ignore_failure = lazy { node['nexus3']['api']['ignore_failure'] }
  @live_stream = lazy { node['nexus3']['api']['live_stream'] }
  @wait = lazy { node['nexus3']['api']['wait'] }
  # Chef will override sensitive back to its global value, so set default to true in init
  @sensitive = lazy { node['nexus3']['api']['sensitive'] }
end
