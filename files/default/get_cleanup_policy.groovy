import org.sonatype.nexus.cleanup.storage.CleanupPolicyStorage;
import groovy.json.JsonOutput;

def policyStorage = container.lookup(CleanupPolicyStorage.class.getName());

if (policyStorage.exists(args)) {
  def policy = policyStorage.get(args);

  return JsonOutput.toJson([
    name: policy.getName(),
    notes: policy.getNotes(),
    format: policy.getFormat(),
    mode: policy.getMode(),
    criteria: policy.getCriteria()
  ]);
}
