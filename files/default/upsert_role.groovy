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
