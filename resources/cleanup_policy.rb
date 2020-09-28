property :policy_name, ::String, name_property: true
property :format, ::String, default: 'raw'.freeze
property :criteria, ::Hash, default: lazy { ::Mash.new }, coerce: proc { |c| c.is_a?(::Mash) ? c : ::Mash.new(c) }
property :mode, ::String, default: 'delete'.freeze
property :notes, ::String, default: ''.freeze
property :api_client, ::Nexus3::Api, identity: true, default: lazy { ::Nexus3::Api.default(node) }

load_current_value do |desired|
  begin
    config = ::JSON.parse(api_client.run_script('get_cleanup_policy', desired.policy_name))
    current_value_does_not_exist! if config.nil?
    ::Chef::Log.debug "Config is: #{config}"
    criteria ::Mash.new(config['criteria'])
    format config['format']
    mode config['mode']
    notes config['notes']
  # We rescue here because during the first run, the policy will not exist yet, so we let Chef know that
  # the resource has to be created.
  rescue ::LoadError, ::Nexus3::ApiError => e
    ::Chef::Log.warn "A '#{e.class}' occured: #{e.message}"
    current_value_does_not_exist!
  end
end

action :create do
  init
  version = if ::Gem::Version.create(node['nexus3']['version'].split('-').first) >= ::Gem::Version.create('3.20.0')
              '.3.20'
            else
              ''
            end

  converge_if_changed do
    nexus3_api "upsert_cleanup_policy #{new_resource.policy_name}" do
      script_name 'upsert_cleanup_policy'
      args name: new_resource.policy_name,
           format: new_resource.format,
           mode: new_resource.mode,
           notes: new_resource.notes,
           criteria: new_resource.criteria

      action %i[create run]
      api_client new_resource.api_client

      content ::Nexus3::Scripts.groovy_content("upsert_cleanup_policy#{version}", node)
    end
  end
end

action :delete do
  init

  nexus3_api "delete_cleanup_policy #{new_resource.policy_name}" do
    action %i[create run]
    script_name 'delete_cleanup_policy'
    args new_resource.policy_name

    content ::Nexus3::Scripts.groovy_content('delete_cleanup_policy', node)

    api_client new_resource.api_client

    not_if { current_resource.nil? }
  end
end

action_class do
  def init
    nexus3_api "get_cleanup_policy #{new_resource.policy_name}" do
      action :create
      script_name 'get_cleanup_policy'
      args new_resource.policy_name
      api_client new_resource.api_client

      content ::Nexus3::Scripts.groovy_content('get_cleanup_policy', node)
    end
  end

  def whyrun_supported?
    true
  end
end
