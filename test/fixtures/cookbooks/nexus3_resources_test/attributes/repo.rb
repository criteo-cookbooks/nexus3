# Test repo resource
default_repo_conf = ::Mash.new(storage: { blobStoreName: 'default', writePolicy: 'ALLOW_ONCE' })
default_maven_conf = default_repo_conf.merge(maven: { versionPolicy: 'RELEASE', layoutPolicy: 'STRICT' })
#  action: create
default['nexus3_resources_test']['repo']['create']['maven']['repo_name'] = 'foo_maven'
default['nexus3_resources_test']['repo']['create']['maven']['repo_type'] = 'maven2-hosted'
default['nexus3_resources_test']['repo']['create']['maven']['attributes'] = default_maven_conf
#  action: delete
default['nexus3_resources_test']['repo']['delete']['maven']['repo_name'] = 'foo_maven'
