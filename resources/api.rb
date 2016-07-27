actions :run, :upload, :delete
default_action :run

attribute :name, kind_of: String, name_attribute: true
attribute :username, kind_of: String, default: 'admin'
attribute :password, kind_of: String, default: 'admin123'
attribute :content, kind_of: [String, NilClass]
attribute :cookbook_name, kind_of: String, default: 'nexus3'
attribute :cookbook_source, kind_of: [String, NilClass]
attribute :args, kind_of: [Array, NilClass]
attribute :type, kind_of: String, default: 'groovy'
attribute :endpoint, kind_of: String, default: 'http://localhost:8081/service/siesta/rest/v1/script'
