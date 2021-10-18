import groovy.json.JsonSlurper
import org.sonatype.nexus.cleanup.storage.CleanupPolicyStorage

def params = new JsonSlurper().parseText(args)
def policyStorage = container.lookup(CleanupPolicyStorage.class.getName()) as CleanupPolicyStorage

def add = false
def cleanupPolicy = policyStorage.get(params.name)
if (!cleanupPolicy) {
    cleanupPolicy = policyStorage.newCleanupPolicy()
    cleanupPolicy.setName(params.name)
    add = true
}

cleanupPolicy.setNotes(params.notes)
cleanupPolicy.setFormat(params.format)
cleanupPolicy.setMode(params.mode)
cleanupPolicy.setCriteria(params.criteria)

if (add) {
    policyStorage.add(cleanupPolicy)
} else {
    policyStorage.update(cleanupPolicy)
}

return true
