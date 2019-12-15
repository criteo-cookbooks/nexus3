# Test role resource
# action: create
default['nexus3_resources_test']['role']['create']['default']['role_name'] = 'baz'
# Test role update
default['nexus3_resources_test']['role']['create']['update_with_privileges']['role_name'] = 'baz'
default['nexus3_resources_test']['role']['create']['update_with_privileges']['privileges'] = %w[nx-blobstores-read nx-ldap-read]
# action: delete
default['nexus3_resources_test']['role']['delete']['default']['role_name'] = 'baz'
