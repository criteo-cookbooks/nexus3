nexus3_user 'uploader' do
  username 'uploader-bot'
  password 'test-1'
  api_endpoint 'http://localhost:8081/service/siesta/rest/v1/script/'
  api_username 'admin'
  api_password 'admin123'

  action :create
end

nexus3_user 'uploader again' do
  username  'uploader-bot'
  password 'test-1'
  api_endpoint 'http://localhost:8081/service/siesta/rest/v1/script/'
  api_username 'admin'
  api_password 'admin123'

  action :create
  notifies :run, 'ruby_block[fail if uploader-bot is created again]', :immediately
end

ruby_block 'fail if uploader-bot is created again' do
  action :nothing
  block { raise 'nexus3_user is not idempotent!' }
end

# This tests that we can delete users.
nexus3_user 'doesnotexist' do
  password 'test-1'
  api_endpoint 'http://localhost:8081/service/siesta/rest/v1/script/'
  api_username 'admin'
  api_password 'admin123'

  action :create
end

nexus3_user 'doesnotexist' do
  api_endpoint 'http://localhost:8081/service/siesta/rest/v1/script/'
  api_username 'admin'
  api_password 'admin123'

  action :delete
end
