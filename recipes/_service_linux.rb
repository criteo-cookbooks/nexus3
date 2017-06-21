def systype
  return 'systemd' if ::File.exist?('/proc/1/comm') && ::File.open('/proc/1/comm').gets.chomp == 'systemd'
  'sysvinit'
end

install_dir = ::File.join(node['nexus3']['path'], "nexus-#{node['nexus3']['version']}")

## Install Linux service
case systype
when 'systemd'
  systemd_unit "#{node['nexus3']['servicename']}.service" do
    content <<-EOU
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
ExecStart=#{install_dir}/bin/nexus start
ExecStop=#{install_dir}/bin/nexus stop
User=#{node['nexus3']['user']}
Restart=on-abort

[Install]
WantedBy=multi-user.target
    EOU
    action [:create]
  end
else
  link "/etc/init.d/#{node['nexus3']['servicename']}" do
    to ::File.join(node['nexus3']['home'], 'bin', 'nexus')
    notifies(:write, 'log[nexus3 is restarting]', :delayed)
  end
end
