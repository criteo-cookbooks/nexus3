nexus3_cleanup_policy 'foo' do
  format 'raw'
  criteria lastBlobUpdated: '604800', lastDownloaded: '259200'
end

nexus3_cleanup_policy 'foo again' do
  policy_name 'foo'
  format 'raw'
  criteria lastBlobUpdated: '604800', lastDownloaded: '259200'
  notifies :run, 'ruby_block[fail if cleanup_policy foo is created again]', :immediately
end

ruby_block 'fail if cleanup_policy foo is created again' do
  action :nothing
  block { raise 'nexus3_cleanup_policy is not idempotent!' }
end

nexus3_cleanup_policy 'bar' do
  action %i(create delete)
end

nexus3_cleanup_policy 'bar again' do
  policy_name 'bar'
  action :delete
  notifies :run, 'ruby_block[fail if cleanup_policy bar is deleted again]', :immediately
end

ruby_block 'fail if cleanup_policy bar is deleted again' do
  action :nothing
  block { raise 'nexus3_cleanup_policy is not idempotent!' }
end
