# uploads 'example' script to repository manager
nexus3_api 'example' do
  content "repository.createMavenHosted('example')"
  action :upload
end
