import groovy.json.JsonOutput
conf = repository.repositoryManager.get(args)?.getConfiguration()
if (conf != null) {
    JsonOutput.toJson([
            repositoryName: conf.getRepositoryName(),
            recipeName: conf.getRecipeName(),
            online: conf.isOnline(),
            attributes: conf.getAttributes()
        ])
}
