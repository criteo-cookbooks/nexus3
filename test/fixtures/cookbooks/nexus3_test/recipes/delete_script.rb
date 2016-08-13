# creates script, then deletes it
nexus3_api 'create bar' do
  script_name 'bar'
  content "repository.createMavenHosted('bar')"
  ignore_failure false
  action :create
end

nexus3_api 'list bar' do
  script_name 'bar'
  ignore_failure false
  action :list
end

nexus3_api 'delete bar' do
  script_name 'bar'
  ignore_failure false
  action :delete
end
