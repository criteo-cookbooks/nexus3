import groovy.json.JsonSlurper
import groovy.json.JsonOutput
import org.sonatype.nexus.repository.config.Configuration

def params = new JsonSlurper().parseText(args)

if (params.multi_policy_cleanup_support && params.attributes.containsKey("cleanup")) {
  // To be compatible with current configs, if we have a String, make it
  // a List, so we can then convert it to a Set.
  if (params.attributes["cleanup"]["policyName"] instanceof String) {
      params.attributes["cleanup"]["policyName"] = [params.attributes["cleanup"]["policyName"]]
  }
  // Ensure we convert policyName to a set, as it is now required by
  // CleanupConfigurationValidator even if we do not use multiple
  // cleanup policies.
  params.attributes["cleanup"]["policyName"] = params.attributes["cleanup"]["policyName"].toSet()
}

def repo = repository.repositoryManager.get(params.name)
Configuration conf
if (repo == null) { // create
    conf = new Configuration(
        repositoryName: params.name,
        recipeName: params.type,
        online: params.online,
        attributes: params.attributes
    )
    repository.createRepository(conf)
} else { // update
    conf = repo.getConfiguration()
    if (conf.getRecipeName() != params.type) {
        throw new Exception("Tried to change recipe for repo ${params.name} to ${params.type}")
    }
    conf.setOnline(params.online)
    conf.setAttributes(params.attributes)
    repo.stop()
    repo.update(conf)
    repo.start()
}

true
