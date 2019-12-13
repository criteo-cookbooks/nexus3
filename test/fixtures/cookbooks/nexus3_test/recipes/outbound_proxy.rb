conf = Mash.new(
  http: {
    host: 'proxy.example.com',
    port: 80,
    auth: {
      username: 'user',
      password: 'secret',
      host: 'ntlmhost',
      domain: 'ntlmdom'
    }
  },
  https: {
    host: 'proxy-sec.example.com',
    port: 443,
    auth: {
      username: 'usersec',
      password: 'secretsec',
      host: 'ntlmhostsec',
      domain: 'ntlmdomsec'
    }
  },
  non_proxy_hosts: ['rubygems.org', '*.chef.io']
)

nexus3_outbound_proxy 'fakeproxy' do
  config conf
end

nexus3_outbound_proxy 'fakeproxy again' do
  config conf
  notifies :run, 'ruby_block[fail if fakeproxy is created again]', :immediately
end

ruby_block 'fail if fakeproxy is created again' do
  action :nothing
  block { raise 'nexus3_outbound_proxy is not idempotent!' }
end
