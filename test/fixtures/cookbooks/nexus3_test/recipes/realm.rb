nexus3_realm 'NuGetApiKey' do
  enable true
end

nexus3_realm 'NuGetApiKey again' do
  realm_name 'NuGetApiKey'
  enable true
  notifies :run, 'ruby_block[fail if NuGetApiKey is enabled again]', :immediately
end

ruby_block 'fail if NuGetApiKey is enabled again' do
  action :nothing
  block { raise 'nexus3_realm is not idempotent!' }
end

nexus3_realm 'NpmToken' do
  enable false
end

nexus3_realm 'NpmToken again' do
  realm_name 'NpmToken'
  enable false
  notifies :run, 'ruby_block[fail if NpmToken is disabled again]', :immediately
end

ruby_block 'fail if NpmToken is disabled again' do
  action :nothing
  block { raise 'nexus3_realm is not idempotent!' }
end
