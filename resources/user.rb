property :username, String, name_property: true
property :password, String, sensitive: true, required: true
property :first_name, String, default: ''
property :last_name, String, default: ''
property :email, String, default: ''
property :roles, Array, default: lazy { [] }, coerce: proc { |r| r.sort }
property :api_client, ::Nexus3::Api, identity: true, desired_state: false, default: lazy { ::Nexus3::Api.default(node) }

load_current_value do |desired|
  begin
    config = ::JSON.parse(api_client.run_script('get_user', username))
    current_value_does_not_exist! if config.nil?
    ::Chef::Log.debug "User config is #{config}"
    first_name config['first_name']
    last_name config['last_name']
    email config['email']
    roles config['roles']

    # Check if we need to change the password.
    if self.class.properties[:password].is_set?(desired)
      begin
        ::Nexus3::Api.new(api_client.endpoint, username, desired.password).request(:get, '/service/metrics/ping')
        password 'Supercalifragilisticexpialidocious-that-does-not-exist-so-maybe-the-resource-will-need-to-converge'
      rescue ::Nexus3::ApiError
        password desired.password
      end
    end
  rescue LoadError, ::Nexus3::ApiError => e
    ::Chef::Log.warn "A '#{e.class}' occurred: #{e.message}"
    current_value_does_not_exist!
  end
end

action :create do
  init

  converge_if_changed do
    nexus3_api "upsert_user #{new_resource.username}" do
      script_name 'upsert_user'
      args username: new_resource.username,
           password: new_resource.password,
           first_name: new_resource.first_name,
           last_name: new_resource.last_name,
           email: new_resource.email,
           roles: new_resource.roles

      action %i[create run]
      api_client new_resource.api_client

      content ::Nexus3::Scripts.groovy_content('upsert_user', node)
    end
  end
end

action :delete do
  init

  nexus3_api "delete_user #{new_resource.username}" do
    script_name 'delete_user'
    args new_resource.username

    action %i[create run]
    api_client new_resource.api_client

    content ::Nexus3::Scripts.groovy_content('delete_user', node)

    not_if { current_resource.nil? }
  end
end

action_class do
  def init
    nexus3_api "get_user #{new_resource.username}" do
      action :create
      script_name 'get_user'
      api_client new_resource.api_client

      content ::Nexus3::Scripts.groovy_content('get_user', node)
    end
  end

  def whyrun_supported?
    true
  end
end
