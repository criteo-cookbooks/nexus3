repo_conf = Mash.new(
  storage: {
    blobStoreName: 'default',
    writePolicy: 'ALLOW_ONCE'
  }
)

group_conf = Mash.new(
  storage: {
    blobStoreName: 'default',
    strictContentTypeValidation: true
  }
)

nexus3_repo 'test1' do
  repo_type 'pypi-hosted'
  attributes repo_conf
end
nexus3_repo 'test2' do
  repo_type 'pypi-hosted'
  attributes repo_conf
end

nexus3_group 'foo-group' do
  attributes group_conf
  group_type 'pypi-group'
  repositories %w(test1 test2)
end

nexus3_group 'foo-group again' do
  group_name 'foo-group'
  group_type 'pypi-group'
  attributes group_conf
  repositories %w(test1 test2)
  notifies :run, 'ruby_block[fail if foo-group is created again]', :immediately
end

ruby_block 'fail if foo-group is created again' do
  action :nothing
  block { raise 'nexus3_group is not idempotent!' }
end

nexus3_group 'bar-group' do
  action :delete
end

nexus3_group 'bar-group again' do
  group_name 'bar-group'
  action :delete
  notifies :run, 'ruby_block[fail if bar-group is deleted again]', :immediately
end

ruby_block 'fail if bar-group is deleted again' do
  action :nothing
  block { raise 'nexus3_group is not idempotent!' }
end
