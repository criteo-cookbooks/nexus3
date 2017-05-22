# creates script, then deletes it
nexus3_api 'bar' do
  content "repository.createMavenHosted('bar')"
  username 'admin'
  password 'admin123'

  action :create
  retries 10
  retry_delay 10
end

nexus3_api 'bar' do
  content ''
  username 'admin'
  password 'admin123'

  action :delete
  retries 10
  retry_delay 10
end
