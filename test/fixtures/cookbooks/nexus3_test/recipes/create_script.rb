# creates or updates 'example' script to repository manager
nexus3_api 'foo 8081' do
  script_name 'foo'
  content "repository.createMavenHosted('foo')"

  action :create
  retries 10
  retry_delay 10
end

nexus3_api 'foo 8082' do
  script_name 'foo'
  content "repository.createMavenHosted('foo')"

  action :create
  retries 10
  retry_delay 10
  api_client ::Nexus3::Api.local(8082, 'admin', 'humdiddle')
end

nexus3_api 'foo again' do
  script_name 'foo'
  content "repository.createMavenHosted('foo')"

  action :create
  notifies :run, 'ruby_block[fail if foo is created again]', :immediately
end

ruby_block 'fail if foo is created again' do
  action :nothing
  block { raise 'nexus3_api is not idempotent!' }
end
