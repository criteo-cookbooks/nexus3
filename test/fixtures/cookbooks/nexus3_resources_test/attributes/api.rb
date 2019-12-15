# Test api resource
#  action: create
default['nexus3_resources_test']['api']['create']['default']['script_name'] = 'foo'
default['nexus3_resources_test']['api']['create']['default']['content'] = 'repository.createMavenHosted("foo")'
default['nexus3_resources_test']['api']['create']['default']['retries'] = 10
default['nexus3_resources_test']['api']['create']['default']['retry_delay'] = 10
# Test to update the script content
default['nexus3_resources_test']['api']['create']['update']['script_name'] = 'foo'
default['nexus3_resources_test']['api']['create']['update']['content'] = 'repository.createMavenHosted("bar")'
#  action: delete
default['nexus3_resources_test']['api']['delete']['default']['script_name'] = 'foo'
