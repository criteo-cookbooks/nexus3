# creates script, then deletes it
nexus3_api 'create bar' do
  script_name 'bar'
  content "repository.createMavenHosted('bar')"
  fail_silently false
  action :create
end

nexus3_api 'list bar' do
  script_name 'bar'
  fail_silently false
  action :list
end

nexus3_api 'delete bar' do
  script_name 'bar'
  fail_silently false
  action :delete
end
