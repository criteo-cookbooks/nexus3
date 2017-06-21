## Install Windows service
install_dir = ::File.join(node['nexus3']['path'], "nexus-#{node['nexus3']['version']}")

batch "install Windows service #{node['nexus3']['servicename']}" do
  code "#{install_dir}/bin/nexus.exe /install #{node['nexus3']['servicename']}"
  action :run
  only_if "sc.exe query #{node['nexus3']['servicename']} | find /i \"EnumQueryServicesStatus:OpenService FAILED\""
end

windows_service node['nexus3']['servicename'].to_s do
  run_as_user node['nexus3']['user']
  start_command "#{install_dir}/bin/nexus.exe /start #{node['nexus3']['servicename']}"
  stop_command "#{install_dir}/bin/nexus.exe /stop #{node['nexus3']['servicename']}"
end
