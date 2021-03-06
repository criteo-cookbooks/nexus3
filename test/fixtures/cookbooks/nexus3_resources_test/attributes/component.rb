# Test component resource
# action: create
default['nexus3_resources_test']['component']['create']['default']['component_name'] = 'maven-asset'
default['nexus3_resources_test']['component']['create']['default']['repo'] = 'maven-write-component'
default['nexus3_resources_test']['component']['create']['default']['type'] = 'maven2'
default['nexus3_resources_test']['component']['create']['default']['asset'] = '/tmp/asset.txt'
default['nexus3_resources_test']['component']['create']['default']['maven2_asset_extension'] = 'txt'
default['nexus3_resources_test']['component']['create']['default']['maven2_version'] = '0.0.1'
default['nexus3_resources_test']['component']['create']['default']['maven2_group_id'] = 'com.example.healthchecks'

default['nexus3_resources_test']['component']['create']['raw']['component_name'] = 'raw-asset'
default['nexus3_resources_test']['component']['create']['raw']['repo'] = 'raw-write-component'
default['nexus3_resources_test']['component']['create']['raw']['type'] = 'raw'
default['nexus3_resources_test']['component']['create']['raw']['asset'] = '/tmp/asset.txt'
default['nexus3_resources_test']['component']['create']['raw']['raw_directory'] = '/'
