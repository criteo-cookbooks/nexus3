property :config, Hash, default: lazy { ::Mash.new }
property :api_client, ::Nexus3::Api, identity: true, default: lazy { ::Nexus3::Api.default(node) }

load_current_value do
  begin
    cfg = ::JSON.parse(api_client.run_script('get_outbound_proxy', nil))
    current_value_does_not_exist! if !cfg.respond_to?(:empty?) || cfg.empty?
    config cfg
    ::Chef::Log.debug "Config is: #{config}"
  # We rescue here because during the first run, the repository will not exist yet, so we let Chef know that
  # the resource has to be created.
  rescue LoadError, ::Nexus3::ApiError => e
    ::Chef::Log.warn "A '#{e.class}' occured: #{e.message}"
    current_value_does_not_exist!
  end
end

action :create do
  init

  converge_if_changed do
    nexus3_api "upsert_outbound_proxy #{new_resource.name}" do
      script_name 'upsert_outbound_proxy'
      args new_resource.config
      action %i[create run]
      api_client new_resource.api_client

      content ::Nexus3::Scripts.groovy_content('upsert_outbound_proxy', node)
    end
  end
end

action :delete do
  init

  nexus3_api "delete_outbound_proxy #{new_resource.name}" do
    action %i[create run]
    script_name 'delete_outbound_proxy'
    content ::Nexus3::Scripts.groovy_content('delete_outbound_proxy', node)

    api_client new_resource.api_client

    not_if { current_resource.nil? }
  end
end

action_class do
  def init
    nexus3_api "get_outbound_proxy #{new_resource.name}" do
      action :create
      script_name 'get_outbound_proxy'
      api_client new_resource.api_client

      content ::Nexus3::Scripts.groovy_content('get_outbound_proxy', node)
    end
  end
end
