# Test task resource
# action: create
default['nexus3_resources_test']['task']['create']['default']['task_name'] = 'bask'
# Test task update
default['nexus3_resources_test']['task']['create']['update_with_properties']['task_name'] = 'bask'
default['nexus3_resources_test']['task']['create']['update_with_properties']['task_source'] = 'InvalidCode'
default['nexus3_resources_test']['task']['create']['update_with_properties']['task_crontab'] = '0 2 * * * ?'
# action :delete
default['nexus3_resources_test']['task']['delete']['default']['task_name'] = 'bask'
