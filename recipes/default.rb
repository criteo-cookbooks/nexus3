install_dir = ::File.join(node['nexus3']['path'], "nexus-#{node['nexus3']['version']}")

## Create user, group and directories
user node['nexus3']['user'] do
  comment 'Nexus 3 user'
  home node['nexus3']['home']
  manage_home false # is linked to install_dir below
  shell '/bin/bash'
end

group node['nexus3']['group'] do
  members node['nexus3']['user']
  append true
end

[install_dir, node['nexus3']['data'],
 ::File.join(install_dir, 'bin'),
 ::File.join(node['nexus3']['data'], 'etc')].each do |dir|
  directory dir do
    recursive true
    owner node['nexus3']['user']
    group node['nexus3']['group']
    mode '0755'
  end
end

## Fetch and install binary
include_recipe 'ark'

# Fetch and un{tar,zip} Nexus3 archive
ark "nexus-#{node['nexus3']['version']}" do
  action :put
  url node['nexus3']['url']
  checksum node['nexus3']['checksum']
  path node['nexus3']['path']
  owner node['nexus3']['user']
  group node['nexus3']['group']
end

## Install configuration from templates
template ::File.join(install_dir, 'bin', 'nexus.rc') do
  source 'nexus.rc.erb'
  variables(user: node['nexus3']['user'])
  mode '0644'
  owner node['nexus3']['user']
  group node['nexus3']['group']
  notifies(:write, "log[#{node['nexus3']['servicename']} is restarting]", :delayed)
end

vmoptions = {}
vmoptions.merge!(node['nexus3']['vmoptions_variables'])
vmoptions['data'] = node['nexus3']['data'] if vmoptions['data'].nil?

template ::File.join(install_dir, 'bin', 'nexus.vmoptions') do
  source 'nexus.vmoptions.erb'
  variables vmoptions
  mode '0644'
  owner node['nexus3']['user']
  group node['nexus3']['group']
  notifies(:write, "log[#{node['nexus3']['servicename']} is restarting]", :delayed)
end

template ::File.join(node['nexus3']['data'], 'etc', 'nexus.properties') do
  source 'nexus.properties.erb'
  variables node['nexus3']['properties_variables']
  mode '0644'
  user node['nexus3']['user']
  group node['nexus3']['group']
  notifies(:write, "log[#{node['nexus3']['servicename']} is restarting]", :delayed)
end

link node['nexus3']['home'] do
  to install_dir
  owner node['nexus3']['user']
  group node['nexus3']['group']
end

include_recipe '::_service_windows' if platform?('windows')
include_recipe '::_service_linux' unless platform?('windows')

service node['nexus3']['servicename'].to_s do
  action [:enable, :start]
end

# This is in case a configuration file change triggers a restart of
# the service; we want to wait until it is ready.
log "#{node['nexus3']['servicename']} is restarting" do
  notifies :restart, "service[#{node['nexus3']['servicename']}]", :immediately
  notifies :create, 'ruby_block[block until operational]', :immediately
  action :nothing
end

# Allow for Nexus to fully start before moving on.
ruby_block 'block until operational' do
  block do
    Chef::Log.info 'Waiting until Nexus is listening on port 8081'
    Nexus3::Helper.wait_until_ready!(node['nexus3']['api']['endpoint'])
  end
  action :nothing
end

# We wait until Nexus is ready to handle queries, as it can take
# around 100s on Kitchen test VMs (Vagrant, EC2, Docker), and tests
# would start failing. It is a good idea to be ready before other
# recipes start creating repositories.
log 'ensure nexus is running' do
  notifies :start, "service[#{node['nexus3']['servicename']}]", :immediately
  notifies :create, 'ruby_block[block until operational]', :immediately
end
