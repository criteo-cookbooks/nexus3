property :username, String, name_property: true
property :password, String, sensitive: true, required: true
property :first_name, String, default: ''
property :last_name, String, default: ''
property :email, String, default: ''
property :roles, Array, default: lazy { [] }
property :api_endpoint, String, identity: true, default: lazy { node['nexus3']['api']['endpoint'] }
property :api_username, String, identity: true, default: lazy { node['nexus3']['api']['username'] }
property :api_password, String, identity: true, sensitive: true, default: lazy { node['nexus3']['api']['password'] }

load_current_value do |desired|
  apiclient = ::Nexus3::Api.new(api_endpoint, api_username, api_password)

  begin
    res = apiclient.run_script('get_user', username)
    current_value_does_not_exist! if res == 'null'
    config = JSON.parse(res)
    current_value_does_not_exist! if config.nil?
    ::Chef::Log.debug "User config is #{config}"
    first_name config['first_name']
    last_name config['last_name']
    email config['email']
    roles config['roles']

    # Check if we need to change the password.
    begin
      ::Nexus3::Api.new(api_endpoint, username, desired.password).request(:get, '/service/metrics/ping')
      password 'Supercalifragilisticexpialidocious-that-does-not-exist-so-maybe-the-resource-will-need-to-converge'
    rescue ::Nexus3::ApiError
      password desired.password
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

      action %i(create run)
      endpoint new_resource.api_endpoint
      username new_resource.api_username
      password new_resource.api_password

      content <<-EOS
import org.sonatype.nexus.security.role.NoSuchRoleException;
import org.sonatype.nexus.security.role.RoleIdentifier;
import org.sonatype.nexus.security.user.User;
import org.sonatype.nexus.security.user.UserManager;
import org.sonatype.nexus.security.user.UserNotFoundException;
import org.sonatype.nexus.security.SecuritySystem;

import groovy.json.JsonSlurper;

def params = new JsonSlurper().parseText(args)

authManager = security.getSecuritySystem().getAuthorizationManager(UserManager.DEFAULT_SOURCE);
// Create a list of available from the list of passed roles. May end up empty if no role exists.
Set<RoleIdentifier> roleList = new HashSet<RoleIdentifier>();
params.roles.each { role ->
    try {
        def newRole = authManager.getRole(role);
        roleList.add(newRole);
    } catch (NoSuchRoleException e) {
        log.warn("No such role: ${role}, trying to set for ${params.username} from Chef");
    }
}

try {
    // Update
    User user = security.securitySystem.getUser(params.username, UserManager.DEFAULT_SOURCE);

    user.setFirstName(params.first_name);
    user.setLastName(params.last_name);
    user.setEmailAddress(params.email);
    user.setRoles(roleList);

    security.securitySystem.updateUser(user);
    security.securitySystem.changePassword(params.username, params.password);
    log.info("Udpdated information for ${params.username} from Chef")
} catch (UserNotFoundException e) {
    // Create
    security.addUser(params.username, params.first_name, params.last_name, params.email, true, params.password, params.roles)
    log.info("Created user ${params.username} from Chef")
}
      EOS
    end
  end
end

action :delete do
  init

  nexus3_api "delete_user #{new_resource.username}" do
    script_name 'delete_user'
    args new_resource.username

    action %i(create run)
    endpoint new_resource.api_endpoint
    username new_resource.api_username
    password new_resource.api_password

    content <<-EOS
import org.sonatype.nexus.security.user.UserManager;

security.securitySystem.deleteUser(args, UserManager.DEFAULT_SOURCE);
    EOS
  end
end

action_class do
  def init
    chef_gem 'httpclient' do
      compile_time true
    end

    nexus3_api "get_user #{new_resource.username}" do
      action :create
      script_name 'get_user'
      endpoint new_resource.api_endpoint
      username new_resource.api_username
      password new_resource.api_password

      content <<-EOS
import org.sonatype.nexus.security.user.UserManager;
import org.sonatype.nexus.security.user.UserNotFoundException;

import groovy.json.JsonOutput;

try {
    def user = security.securitySystem.getUser(args, UserManager.DEFAULT_SOURCE);
    if (user) {
        return JsonOutput.toJson([
            username: user.getUserId(),
            first_name: user.getFirstName(),
            last_name: user.getLastName(),
            email: user.getEmailAddress(),
            roles: user.getRoles().collect { role -> role.getRoleId() }
        ])
    }
} catch (UserNotFoundException e) {
    return null;
}
      EOS
    end
  end

  def whyrun_supported?
    true
  end
end
