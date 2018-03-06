nexus3_task 'foo'

nexus3_task 'foo again' do
  task_name 'foo'
  notifies :run, 'ruby_block[fail if foo is created again]', :immediately
end

ruby_block 'fail if foo is created again' do
  action :nothing
  block { raise 'nexus3_task is not idempotent!' }
end

nexus3_task 'bar' do
  action %i(create delete)
end

nexus3_task 'bar again' do
  task_name 'bar'
  action :delete
  notifies :run, 'ruby_block[fail if bar is deleted again]', :immediately
end

ruby_block 'fail if bar is deleted again' do
  action :nothing
  block { raise 'nexus3_task is not idempotent!' }
end
