# create and run maven  hosted repository
nexus3_api 'maven-internal' do
  content "repository.createMavenHosted('maven-internal')"
  action :run
end
