# adds or updates 'anonymous' script on repository manager and executes it with an argument
nexus3_api 'anonymous' do
  content 'repository.repositoryManager.browse()'

  action %i[create run]
  retries 10
  retry_delay 10
end
