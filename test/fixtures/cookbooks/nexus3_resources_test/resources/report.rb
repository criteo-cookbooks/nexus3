property :test_resources, ::Hash, required: true

action :validate do
  failed = []
  non_updated = []
  non_idempotent = []
  new_resource.test_resources.each do |resource, action_name|
    begin
      # Run the action once, the resource must be updated
      resource.run_action(action_name)
      non_updated << resource unless resource.updated_by_last_action?
      # Run the action twice, the resource must not be updated
      resource.run_action(action_name)
      non_idempotent << resource if resource.updated_by_last_action?
    rescue StandardError => e
      ::Chef::Log.error e
      failed << resource
    end
  end

  raise <<~REPORT unless (non_updated + non_idempotent + failed).empty?
    Resources validation error:
    * Not updated at first run:#{format_resource_report(non_updated)}
    * Still updated at second run:#{format_resource_report(non_idempotent)}
    * With error:#{format_resource_report(failed)}
  REPORT
end
def format_resource_report(resources)
  return ' None' if resources.empty?

  resources.map { |r| "\n  - #{r.declared_key}" }.join
end
