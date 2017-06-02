usr = node['nexus3']['user']
grp = node['nexus3']['group']
homedir = node['nexus3']['home']
install_dir = ::File.join(node['nexus3']['path'], "nexus-#{node['nexus3']['version']}")
data_dir = node['nexus3']['data']

## Create user, group and directories
user usr do
  comment 'Nexus 3 user'
  home homedir
  manage_home false # is linked to install_dir below
  shell '/bin/bash'
end

group grp do
  members usr
  append true
end

[install_dir, data_dir, ::File.join(install_dir, 'bin'), ::File.join(data_dir, 'etc')].each do |dir|
  directory dir do
    recursive true
    owner usr
    group grp
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
  owner usr
  group grp

  notifies(:run, 'batch[install Nexus service]', :immediately) if platform?('windows')
end

if platform?('windows')
  batch 'install Nexus service' do
    code "#{install_dir}/bin/nexus.exe /install"
    action :nothing
    notifies(:write, 'log[nexus3 is restarting]')
  end
end

## Install configuration from templates
template ::File.join(install_dir, 'bin', 'nexus.rc') do
  source 'nexus.rc.erb'
  variables(user: usr)
  mode '0644'
  owner usr
  group grp
  notifies(:write, 'log[nexus3 is restarting]')
end

vmoptions = {}
vmoptions.merge!(node['nexus3']['vmoptions_variables'])
vmoptions['data'] = node['nexus3']['data'] if vmoptions['data'].nil?

template ::File.join(install_dir, 'bin', 'nexus.vmoptions') do
  source 'nexus.vmoptions.erb'
  variables vmoptions
  mode '0644'
  owner usr
  group grp
  notifies(:write, 'log[nexus3 is restarting]')
end

template ::File.join(node['nexus3']['data'], 'etc', 'nexus.properties') do
  source 'nexus.properties.erb'
  variables node['nexus3']['properties_variables']
  mode '0644'
  user usr
  group grp
  notifies(:write, 'log[nexus3 is restarting]')
end

link homedir do
  to install_dir
  owner usr
  group grp
end

## Install Unix service
def systype
  return 'windows' if platform?('windows')
  return 'systemd' if ::File.exist?('/proc/1/comm') && ::File.open('/proc/1/comm').gets.chomp == 'systemd'
  'sysvinit'
end

case systype
when 'windows'
  batch 'install Windows service' do
    code "#{install_dir}/bin/nexus.exe /install nexus3"
    action :run
  end
when 'systemd'
  systemd_unit 'nexus3.service' do
    content <<-EOU
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
ExecStart=#{install_dir}/bin/nexus start
ExecStop=#{install_dir}/bin/nexus stop
User=#{usr}
Restart=on-abort

[Install]
WantedBy=multi-user.target
    EOU
    action [:create]
  end
else
  link '/etc/init.d/nexus3' do
    to ::File.join(homedir, 'bin', 'nexus')
    notifies(:write, 'log[nexus3 is restarting]')
  end
end

if platform?('windows')
  windows_service 'nexus3' do
    run_as_user usr
  end
end

# TODO: define servicename in attributes?
service 'nexus3' do
  action :enable
end

# This is in case a configuration file change triggers a restart of
# the service; we want to wait until it is ready.
log 'nexus3 is restarting' do
  notifies :restart, 'service[nexus3]', :immediately
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

log 'ensure nexus is running' do
  notifies :start, 'service[nexus3]', :immediately
  notifies :create, 'ruby_block[block until operational]', :immediately
end
