property :username, String, name_attribute: true, desired_state: false, identity: true
property :password, String, desired_state: false, identity: true, sensitive: true
property :first_name, String, desired_state: false, identity: true, default: ''
property :last_name, String, desired_state: false, identity: true, default: ''
property :email, String, desired_state: false, identity: true, default: ''
property :roles, Array,  desired_state: false, identity: true, default: []
property :api_endpoint, String, desired_state: false, identity: true,
                                default: lazy { node['nexus3']['api']['endpoint'] }
property :api_username, String, desired_state: false, identity: true,
                                default: lazy { node['nexus3']['api']['username'] }
property :api_password, String, desired_state: false, identity: true, sensitive: true,
                                default: lazy { node['nexus3']['api']['password'] }

load_current_value do |desired|
  api_endpoint desired.api_endpoint
  api_username desired.api_username
  api_password desired.api_password

  def apiclient
    @apiclient ||= ::Nexus3::Api.new(api_endpoint, api_username, api_password)
  end

  begin
    res = apiclient.run_script('search_user', desired.username)
    current_value_does_not_exist! if res == 'null'
    user = res
    ::Chef::Log.warn "User is #{user}"
  rescue LoadError, ::Nexus3::ApiError => e
    ::Chef::Log.warn "A '#{e.class}' occurred: #{e.message}"
    current_value_does_not_exist!
  end
end

action :create do
  init

  converge_if_changed do
    nexus3_api "create_user #{new_resource.username}" do
      script_name 'create_user'
      args username: new_resource.username,
           password: new_resource.password,
           first_name: new_resource.first_name,
           last_name: new_resource.last_name,
           email: new_resource.email,
           roles: new_resource.roles

      action %i(create run)
      endpoint new_resource.api_endpoint
      username new_resource.api_username
      password new_resource.api_password

      content <<-EOS
import groovy.json.JsonSlurper

def params = new JsonSlurper().parseText(args)

security.addUser(params.username, params.first_name, params.last_name, params.email, true, params.password, params.roles)
      EOS
    end
  end
end

action :delete do
  init

  nexus3_api "delete_user #{new_resource.username}" do
    script_name 'delete_user'
    args username: new_resource.username

    action %i(create run)
    endpoint new_resource.api_endpoint
    username new_resource.api_username
    password new_resource.api_password

    content <<-EOS
import groovy.json.JsonSlurper

def params = new JsonSlurper().parseText(args)

security.securitySystem.deleteUser(params.username, "default")
    EOS
  end
end

action_class do
  def init
    chef_gem 'httpclient' do
      compile_time true
    end

    nexus3_api "search_user #{new_resource.username}" do
      action :create
      script_name 'search_user'
      endpoint new_resource.api_endpoint
      username new_resource.api_username
      password new_resource.api_password

      content <<-EOS
def user = security.securitySystem.getUser(args);
if (user) {
  return user.getUserId();
}
      EOS
    end
  end
end
