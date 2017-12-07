property :script_name, String, name_attribute: true
property :content, String, default: ''.freeze
property :args, [Hash, String, NilClass], desired_state: false
property :endpoint, String, desired_state: false, identity: true, default: node['nexus3']['api']['endpoint']
property :username, String, desired_state: false, identity: true, default: 'admin'.freeze
property :password, String, desired_state: false, identity: true, sensitive: true, default: 'admin123'.freeze

def apiclient
  @apiclient ||= ::Nexus3::Api.new(endpoint, username, password)
end

load_current_value do |desired|
  endpoint desired.endpoint
  username desired.username
  password desired.password

  begin
    response = JSON.parse(apiclient.request(:get, "script/#{desired.script_name}"))
    content response['content'] if response.is_a?(Hash) && response.key?('content')
  rescue LoadError, ::Nexus3::ApiError => e
    ::Chef::Log.warn "A '#{e.class}' occured: #{e.message}"
    current_value_does_not_exist!
  end
end

action :create do
  chef_gem 'httpclient'

  converge_if_changed do
    apiclient.request(:delete, "script/#{new_resource.script_name}") unless current_resource.nil?
    apiclient.request(:post, '', 'application/json', name: new_resource.script_name, type: 'groovy',
                                                     content: new_resource.content)
  end
end

action :run do
  chef_gem 'httpclient'

  converge_by "running script #{new_resource.script_name}" do
    apiclient.run_script(new_resource.script_name, new_resource.args)
  end
end

action :delete do
  chef_gem 'httpclient'

  unless current_resource.nil?
    converge_by "deleting script #{new_resource.script_name}" do
      apiclient.request(:delete, "script/#{new_resource.script_name}")
    end
  end
end
