default['nexus3']['api']['script_cookbook'] = 'nexus3'
default['nexus3']['api']['type'] = 'groovy'
default['nexus3']['api']['host'] = 'http://localhost:8081'
default['nexus3']['api']['endpoint'] = "#{node['nexus3']['api']['host']}/service/siesta/rest/v1/script"
default['nexus3']['api']['ignore_failure'] = true
default['nexus3']['api']['live_stream'] = false
default['nexus3']['api']['wait'] = 600 # 10 minutes
default['nexus3']['api']['sensitive'] = true
