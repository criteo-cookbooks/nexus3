# Test task resource
# action: create
default['nexus3_resources_test']['task']['create']['default']['task_name'] = 'bask'
default['nexus3_resources_test']['task']['create']['default']['task_type'] = 'script'

default['nexus3_resources_test']['task']['create']['compact']['task_name'] = 'compact_default'
default['nexus3_resources_test']['task']['create']['compact']['task_type'] = 'blobstore.compact'
default['nexus3_resources_test']['task']['create']['compact']['crontab'] = '0 15 4 * * ?'
default['nexus3_resources_test']['task']['create']['compact']['properties'] = { 'blobstoreName' => 'default' }

# Test task update
default['nexus3_resources_test']['task']['create']['update_with_properties']['task_name'] = 'bask'
default['nexus3_resources_test']['task']['create']['update_with_properties']['task_type'] = 'script'
default['nexus3_resources_test']['task']['create']['update_with_properties']['crontab'] = '0 2 * * * ?'
default['nexus3_resources_test']['task']['create']['update_with_properties']['properties'] = { 'language' => 'lang', 'source' => 'log.info("Hello task");' }

# action :delete
default['nexus3_resources_test']['task']['delete']['default']['task_name'] = 'bask'
