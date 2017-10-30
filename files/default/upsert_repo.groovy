import groovy.json.JsonSlurper
import groovy.json.JsonOutput
import org.sonatype.nexus.repository.config.Configuration

def params = new JsonSlurper().parseText(args)

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
