# creates or updates 'example' script to repository manager
nexus3_api 'create foo' do
  script_name 'foo'
  content "repository.createMavenHosted('foo')"
  action :create
end
