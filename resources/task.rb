property :task_name, String, name_property: true
property :task_source, String, default: ''.freeze
property :task_crontab, String, default: '0 1 * * * ?'.freeze
property :api_client, ::Nexus3::Api, identity: true, default: lazy { ::Nexus3::Api.default(node) }

load_current_value do |desired|
  begin
    config = ::JSON.parse(api_client.run_script('get_task', desired.task_name))
    current_value_does_not_exist! if config.nil?
    ::Chef::Log.debug "Config is: #{config}"
    task_source config['source']
  # We rescue here because during the first run, the task will not exist yet, so we let Chef know that
  # the resource has to be created.
  rescue LoadError, ::Nexus3::ApiError => e
    ::Chef::Log.warn "A '#{e.class}' occured: #{e.message}"
    current_value_does_not_exist!
  end
end

action :create do
  init

  converge_if_changed do
    nexus3_api "upsert_task #{new_resource.task_name}" do
      script_name 'upsert_task'
      args name: new_resource.task_name,
           source: new_resource.task_source,
           crontab: new_resource.task_crontab

      action %i(create run)
      api_client new_resource.api_client

      content ::Nexus3::Scripts.groovy_content('upsert_task', node)
    end
  end
end

action :delete do
  init

  converge_if_changed do
    nexus3_api "delete_task #{new_resource.task_name}" do
      action %i(create run)
      script_name 'delete_task'
      args new_resource.task_name

      content ::Nexus3::Scripts.groovy_content('delete_task', node)

      api_client new_resource.api_client

      not_if { current_resource.nil? }
    end
  end
end

action_class do
  def init
    chef_gem 'httpclient' do
      compile_time true
    end

    nexus3_api "get_task #{new_resource.task_name}" do
      action :create
      script_name 'get_task'
      args new_resource.task_name
      api_client new_resource.api_client

      content ::Nexus3::Scripts.groovy_content('get_task', node)
    end
  end

  def whyrun_supported?
    true
  end
end
