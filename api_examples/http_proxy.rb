# another proxy server in the data center is the gate to the internet and therefore
# any remote proxy repositories the repository manager therefore needs to connect to
# it as HTTP/HTTPS proxy and authenticate to be able to retrieve remote content
nexus3_api 'http-proxy' do
  content "core.httpProxyWithBasicAuth('webproxy', 9999, 'repomgr', 'letmethrough')"
  action :run
end
