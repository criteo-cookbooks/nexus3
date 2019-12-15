# Test group resource
default_repo_conf = ::Mash.new(storage: { blobStoreName: 'default', writePolicy: 'ALLOW_ONCE' })
default_group_conf = ::Mash.new(storage: { blobStoreName: 'default', strictContentTypeValidation: true })

# Create 2 pypi repo first
default['nexus3_resources_test']['repo']['create']['for_group1']['repo_name'] = 'foo_pypi1'
default['nexus3_resources_test']['repo']['create']['for_group1']['repo_type'] = 'pypi-hosted'
default['nexus3_resources_test']['repo']['create']['for_group1']['attributes'] = default_repo_conf
default['nexus3_resources_test']['repo']['create']['for_group2']['repo_name'] = 'foo_pypi2'
default['nexus3_resources_test']['repo']['create']['for_group2']['repo_type'] = 'pypi-hosted'
default['nexus3_resources_test']['repo']['create']['for_group2']['attributes'] = default_repo_conf

#  action: create
default['nexus3_resources_test']['group']['create']['default']['group_name'] = 'foo_pypi_group'
default['nexus3_resources_test']['group']['create']['default']['group_type'] = 'pypi-group'
default['nexus3_resources_test']['group']['create']['default']['repositories'] = %w[foo_pypi1 foo_pypi2]
default['nexus3_resources_test']['group']['create']['default']['attributes'] = default_group_conf
# test resource update
default['nexus3_resources_test']['group']['create']['update']['group_name'] = 'foo_pypi_group'
default['nexus3_resources_test']['group']['create']['update']['group_type'] = 'pypi-group'
default['nexus3_resources_test']['group']['create']['update']['repositories'] = %w[foo_pypi1]
default['nexus3_resources_test']['group']['create']['update']['attributes'] = default_group_conf
#  action: delete
default['nexus3_resources_test']['group']['delete']['default']['group_name'] = 'foo_pypi_group'
