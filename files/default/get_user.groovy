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
