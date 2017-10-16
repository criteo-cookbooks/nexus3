property :role_name, String, name_property: true
property :description, String, default: ''.freeze
property :roles, Array, default: []
property :privileges, Array, default: []
property :api_endpoint, String, identity: true, default: lazy { node['nexus3']['api']['endpoint'] }
property :api_username, String, identity: true, default: lazy { node['nexus3']['api']['username'] }
property :api_password, String, identity: true, sensitive: true, default: lazy { node['nexus3']['api']['password'] }

load_current_value do |desired|
  apiclient = ::Nexus3::Api.new(api_endpoint, api_username, api_password)

  begin
    res = apiclient.run_script('get_role', desired.role_name)
    current_value_does_not_exist! if res == 'null'
    config = JSON.parse(res)
    ::Chef::Log.warn "Role config is #{config}"
    role_name config['role']
    description config['description']
    roles config['roles'].sort!
    privileges config['privileges'].sort!
  rescue LoadError, ::Nexus3::ApiError => e
    ::Chef::Log.warn "A '#{e.class}' occurred: #{e.message}"
    current_value_does_not_exist!
  end
end

action :create do
  init

  converge_if_changed do
    nexus3_api "upsert_role #{new_resource.role_name}" do
      script_name 'upsert_role'
      args rolename: new_resource.role_name,
           description: new_resource.description,
           role_list: new_resource.roles,
           privilege_list: new_resource.privileges

      action %i(create run)
      endpoint new_resource.api_endpoint
      username new_resource.api_username
      password new_resource.api_password

      content <<-EOS
import org.sonatype.nexus.security.user.UserManager;
import org.sonatype.nexus.security.role.NoSuchRoleException;

import groovy.json.JsonSlurper;

def params = new JsonSlurper().parseText(args);

authManager = security.getSecuritySystem().getAuthorizationManager(UserManager.DEFAULT_SOURCE);
def existingRole = null;

try {
    existingRole = authManager.getRole(params.rolename);
} catch (NoSuchRoleException ignored) {
    // Could not find role, ignoring.
}

privileges = (params.privilege_list == null ? new HashSet() : params.privilege_list.toSet());
roles = (params.role_list == null ? new HashSet() : params.role_list.toSet());

if (existingRole != null) {
    existingRole.setName(params.rolename);
    existingRole.setDescription(params.description);
    existingRole.setPrivileges(privileges);
    existingRole.setRoles(roles);
    authManager.updateRole(existingRole);
    log.info("Updated role ${params.rolename} from Chef");
} else {
    // Let's make role ID == role name by convention.
    security.addRole(params.rolename, params.rolename, params.description, privileges.toList(), roles.toList());
    log.info("Added role ${params.rolename} from Chef");
}
      EOS
    end
  end
end

action :delete do
  init

  converge_if_changed do
    nexus3_api "delete_role #{new_resource.role_name}" do
      script_name 'delete_role'
      args new_resource.role_name

      action %i(create run)
      endpoint new_resource.api_endpoint
      username new_resource.api_username
      password new_resource.api_password

      content <<-EOS
import org.sonatype.nexus.security.user.UserManager;
import org.sonatype.nexus.security.role.NoSuchRoleException;

authManager = security.getSecuritySystem().getAuthorizationManager(UserManager.DEFAULT_SOURCE);
try {
    existingRole = authManager.getRole(args);
    log.info("Deleting role ${existingRole.getName()}");
    authManager.deleteRole(existingRole.getRoleId());
} catch (NoSuchRoleException ignored) {
    // No such role, ignoring.
}
    EOS
    end
  end
end

action_class do
  def init
    chef_gem 'httpclient' do
      compile_time true
    end

    nexus3_api "get_role #{new_resource.role_name}" do
      action :create
      script_name 'get_role'
      endpoint new_resource.api_endpoint
      username new_resource.api_username
      password new_resource.api_password
      args new_resource.role_name

      content <<-EOS
import org.sonatype.nexus.security.user.UserManager;
import org.sonatype.nexus.security.role.NoSuchRoleException;

import groovy.json.JsonOutput;

authManager = security.getSecuritySystem().getAuthorizationManager(UserManager.DEFAULT_SOURCE);
try {
    role = authManager.getRole(args);
    return JsonOutput.toJson([
      role: role.getName(),
      description: role.getDescription(),
      roles: role.getRoles().toSorted(),
      privileges: role.getPrivileges().toSorted()
    ]);
} catch (NoSuchRoleException) {
    return null;
}
      EOS
    end
  end

  def whyrun_supported?
    true
  end
end
