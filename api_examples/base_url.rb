# the repository manager is hosted behind a proxy server or load balancer that redirects ports,
# manages HTTPS and is configured with a DNS name so we need to set the base URL
nexus3_api 'base-url' do
  content "core.baseUrl('https://repo.example.com')"
  action :run
end
