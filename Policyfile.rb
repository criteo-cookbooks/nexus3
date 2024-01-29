name 'nexus3'

run_list %w[nexus3_test nexus3_resources_test nexus3_test::integration]

default_source :community

# Current cookbook
cookbook 'nexus3', path: '.'
# Test cookbooks
cookbook 'nexus3_test', path: 'test/fixtures/cookbooks/nexus3_test'
cookbook 'nexus3_resources_test', path: 'test/fixtures/cookbooks/nexus3_resources_test'

# Test attributes
default['nexus3_test']['connection_retries'] = 10
default['nexus3']['desired_heap_size'] = '2G'
default['nexus3']['api']['sensitive'] = false
