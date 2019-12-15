# Test user resource
# action: create
default['nexus3_resources_test']['user']['create']['default']['username'] = 'bur'
default['nexus3_resources_test']['user']['create']['default']['password'] = 'word'
# Test user update
default['nexus3_resources_test']['user']['create']['update_with_properties']['username'] = 'bur'
default['nexus3_resources_test']['user']['create']['update_with_properties']['password'] = 'secret'
default['nexus3_resources_test']['user']['create']['update_with_properties']['last_name'] = 'last_blah'
default['nexus3_resources_test']['user']['create']['update_with_properties']['first_name'] = 'first_blah'
default['nexus3_resources_test']['user']['create']['update_with_properties']['email'] = 'bur@bla.h'
default['nexus3_resources_test']['user']['create']['update_with_properties']['roles'] = %w[nx-anonymous nx-admin]
# action :delete
default['nexus3_resources_test']['user']['delete']['default']['username'] = 'bur'
default['nexus3_resources_test']['user']['delete']['default']['password'] = 'secret'
