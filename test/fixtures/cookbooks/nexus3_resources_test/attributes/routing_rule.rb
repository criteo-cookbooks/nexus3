# Test routing_rule resource
#  action: create
default['nexus3_resources_test']['routing_rule']['create']['default']['name'] = 'blockindex'
default['nexus3_resources_test']['routing_rule']['create']['default']['mode'] = 'BLOCK'
default['nexus3_resources_test']['routing_rule']['create']['default']['matchers'] = ['.*/index']
# Test update
default['nexus3_resources_test']['routing_rule']['create']['add_matcher']['name'] = 'blockindex'
default['nexus3_resources_test']['routing_rule']['create']['add_matcher']['mode'] = 'BLOCK'
default['nexus3_resources_test']['routing_rule']['create']['add_matcher']['matchers'] = ['.*/index', '.*/index.htm']
#  action: delete
default['nexus3_resources_test']['routing_rule']['delete']['delete_rule']['name'] = 'blockindex'
