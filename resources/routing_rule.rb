property :rule_name, ::String, name_property: true
property :description, ::String, default: ''.freeze
property :mode, ::String, equal_to: %w[BLOCK ALLOW], default: 'BLOCK'.freeze
property :matchers, Array, default: lazy { [] }, coerce: proc { |m| m.sort }
property :api_client, ::Nexus3::Api, identity: true, default: lazy { ::Nexus3::Api.default(node) }

load_current_value do |desired|
  begin
    config = api_client.routing_rule(desired.rule_name)
    current_value_does_not_exist! if config.nil?
    ::Chef::Log.debug "Config is: #{config}"
    description config['description']
    mode config['mode']
    matchers config['matchers']
  # We rescue here because during the first run, the policy will not exist yet, so we let Chef know that
  # the resource has to be created.
  rescue ::LoadError, ::Nexus3::ApiError => e
    ::Chef::Log.warn "A '#{e.class}' occured: #{e.message}"
    current_value_does_not_exist!
  end
end

action :create do
  converge_if_changed do
    converge_by("#{current_resource.nil? ? 'Creating' : 'Updating'} routing rule #{new_resource.rule_name}") do
      method = current_resource.nil? ? 'add' : 'update'
      new_resource.api_client.public_send("#{method}_routing_rule", {
                                            'name' => new_resource.rule_name,
                                            'description' => new_resource.description,
                                            'mode' => new_resource.mode,
                                            'matchers' => new_resource.matchers
                                          })
    end
  end
end

action :delete do
  unless current_resource.nil?
    converge_by("Deleting routing rule #{new_resource.rule_name}") do
      new_resource.api_client.delete_routing_rule(new_resource.rule_name)
    end
  end
end

action_class do
  def whyrun_supported?
    true
  end
end
