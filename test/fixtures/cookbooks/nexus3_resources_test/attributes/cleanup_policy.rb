# Test cleanup_policy resource
#  action: create
default['nexus3_resources_test']['cleanup_policy']['create']['default']['policy_name'] = 'foo'
default['nexus3_resources_test']['cleanup_policy']['create']['default']['format'] = 'raw'
default['nexus3_resources_test']['cleanup_policy']['create']['default']['criteria'] = { lastBlobUpdated: '604800', lastDownloaded: '259200' }
#  action: delete
default['nexus3_resources_test']['cleanup_policy']['delete']['default']['policy_name'] = 'foo'
