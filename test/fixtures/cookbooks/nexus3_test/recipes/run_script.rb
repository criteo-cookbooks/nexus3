# uploads 'example' script to repository manager and executes it
nexus3_api 'example' do
  content "repository.createMavenHosted('example')"
  action :run
end
