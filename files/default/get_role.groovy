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
