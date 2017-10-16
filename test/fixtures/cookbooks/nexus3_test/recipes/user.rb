nexus3_user 'uploader' do
  username 'uploader-bot'
  password 'test-1'
end

nexus3_user 'uploader again' do
  username  'uploader-bot'
  password 'test-1'

  notifies :run, 'ruby_block[fail if uploader-bot is created again]', :immediately
end

ruby_block 'fail if uploader-bot is created again' do
  action :nothing
  block { raise 'nexus3_user is not idempotent!' }
end

# This tests that we can update users.
nexus3_user 'uploader2-bot' do
  password 'test-2'
end

nexus3_user 'uploader2 update' do
  username 'uploader2-bot'
  password 'test-2'
  first_name 'uploader2'
  last_name 'bot'
  email 'uploader2@example.com'
end

# This tests that we can change a password.
nexus3_user 'test-with-pass' do
  password 'test-1'
end

nexus3_user 'test-with-pass updates password' do
  username 'test-with-pass'
  password 'newpassword'
end

nexus3_user 'test-with-pass does not update password a second time' do
  username 'test-with-pass'
  password 'newpassword'

  notifies :run, 'ruby_block[fail if password was changed]', :immediately
end

ruby_block 'fail if password was changed' do
  action :nothing
  block { raise 'nexus3_user is not idempotent!' }
end

# This tests that we can delete users.
nexus3_user 'doesnotexist' do
  password 'test-1'
end

nexus3_user 'doesnotexist' do
  password 'test-1'
  action :delete
end
