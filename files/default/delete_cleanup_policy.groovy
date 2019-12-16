import org.sonatype.nexus.cleanup.storage.CleanupPolicyStorage;
import groovy.json.JsonOutput;

def policyStorage = container.lookup(CleanupPolicyStorage.class.getName());
if (policyStorage.exists(args)) {
  policyStorage.remove(policyStorage.get(args));
  return true;
}

return false;
