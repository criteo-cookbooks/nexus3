property :script_name, String, name_property: true
property :content, String, default: ''.freeze
property :args, [Hash, String, NilClass], desired_state: false
property :api_client, ::Nexus3::Api, identity: true, default: lazy { ::Nexus3::Api.default(node) }

load_current_value do |desired|
  begin
    response = api_client.script(desired.script_name)
    content response['content'] if response.is_a?(Hash) && response.key?('content')
  rescue LoadError, ::Nexus3::ApiError => e
    ::Chef::Log.warn "A '#{e.class}' occured: #{e.message}"
    current_value_does_not_exist!
  end
end

action :create do
  converge_if_changed do
    new_resource.api_client.delete_script(new_resource.script_name) unless current_resource.nil?
    new_resource.api_client.add_script(name: new_resource.script_name, type: 'groovy', content: new_resource.content)
  end
end

action :run do
  converge_by "running script #{new_resource.script_name}" do
    new_resource.api_client.run_script(new_resource.script_name, new_resource.args)
  end
end

action :delete do
  unless current_resource.nil?
    converge_by "deleting script #{new_resource.script_name}" do
      new_resource.api_client.delete_script(new_resource.script_name)
    end
  end
end
