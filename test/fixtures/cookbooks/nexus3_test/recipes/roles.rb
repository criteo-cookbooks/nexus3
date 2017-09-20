nexus3_role 'foo'

nexus3_role 'foo again' do
  role_name 'foo'
  notifies :run, 'ruby_block[fail if foo is created again]', :immediately
end

ruby_block 'fail if foo is created again' do
  action :nothing
  block { raise 'nexus3_role is not idempotent!' }
end

nexus3_role 'bar' do
  action %i(create delete)
end

nexus3_role 'bar again' do
  role_name 'bar'
  action :delete
  notifies :run, 'ruby_block[fail if bar is deleted again]', :immediately
end

ruby_block 'fail if bar is deleted again' do
  action :nothing
  block { raise 'nexus3_role is not idempotent!' }
end
