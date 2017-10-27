def repo = repository.repositoryManager.get(args)
if (repo == null) {
    return false
}
repository.repositoryManager.delete(args)
true
