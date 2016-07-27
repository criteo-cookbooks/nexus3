nexus3_api 'createMavenPrivateRepo' do
  content "repository.createMavenHosted('private')"
  action :run
end
