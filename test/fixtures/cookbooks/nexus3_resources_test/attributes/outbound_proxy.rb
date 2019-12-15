# Test outbound_proxy resource
default_auth = ::Mash.new(username: 'user', password: 'secret', host: 'ntlmhost', domain: 'ntlmdom')
default_proxy_conf = Mash.new(non_proxy_hosts: ['rubygems.org', '*.chef.io'],
                              http: { host: 'proxy.example.com', port: 80, auth: default_auth },
                              https: { host: 'proxy-sec.example.com', port: 443, auth: default_auth })
#  action: create
default['nexus3_resources_test']['outbound_proxy']['create']['default']['config'] = default_proxy_conf
#  action: delete
default['nexus3_resources_test']['outbound_proxy']['delete']['default']
