include_recipe 'nexus3_test'

tested_resources = {}
node['nexus3_resources_test'].each do |resource_name, actions|
  resource_type = "nexus3_#{resource_name}"
  actions.each do |action_name, instances|
    instances.each do |instance_id, instance_values|
      instance_name = "#{action_name} - #{instance_id}"
      resource = declare_resource(resource_type, instance_name) do
        instance_values.each { |k, v| send(k, v) }
        action :nothing # Do nothing here, the report resource will try to converge them twice
      end
      tested_resources[resource] = action_name
    end
  end
end

nexus3_resources_test_report 'validation' do
  test_resources tested_resources
end
