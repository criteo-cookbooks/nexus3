# Test repo resource
default_repo_conf = ::Mash.new(storage: { blobStoreName: 'default', writePolicy: 'ALLOW_ONCE' })
default_maven_conf = default_repo_conf.merge(maven: { versionPolicy: 'RELEASE', layoutPolicy: 'STRICT' }, component: {})
default_maven_proxy_conf = default_maven_conf.merge('maven-indexer': {}, proxy: { remoteUrl: 'http://localhost:8081' }, httpclient: {}, negativeCache: {}, replication:{})
#  action: create
default['nexus3_resources_test']['repo']['create']['maven']['repo_name'] = 'foo_maven'
default['nexus3_resources_test']['repo']['create']['maven']['repo_type'] = 'maven2-hosted'
default['nexus3_resources_test']['repo']['create']['maven']['attributes'] = default_maven_conf
default['nexus3_resources_test']['repo']['create']['maven-proxy']['repo_name'] = 'foo_maven_proxy'
default['nexus3_resources_test']['repo']['create']['maven-proxy']['repo_type'] = 'maven2-proxy'
default['nexus3_resources_test']['repo']['create']['maven-proxy']['attributes'] = default_maven_proxy_conf
default['nexus3_resources_test']['repo']['create']['maven-proxy']['routing_rule_name'] = 'mavenrule'
#  action: delete
default['nexus3_resources_test']['repo']['delete']['maven']['repo_name'] = 'foo_maven'
default['nexus3_resources_test']['repo']['delete']['maven-proxy']['repo_name'] = 'foo_maven_proxy'
