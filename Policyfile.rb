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
default['nexus3']['api']['sensitive'] = false

# Constraints for Chef 14 :(
cookbook 'ark', '= 5.1.1' # Drop constraint when requiring Chef >= 15
cookbook 'homebrew', '= 5.3.1' # Drop constraint when requiring Chef >= 15
