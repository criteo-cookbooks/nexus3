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
