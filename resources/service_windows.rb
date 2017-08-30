provides :nexus3_service_windows

provides :nexus3_service, os: 'windows'

property :instance_name, String, name_property: true
property :install_dir, String
property :nexus3_user, String
property :nexus3_group, String

action :enable do
  batch "install Windows service nexus3_#{new_resource.instance_name}" do
    code "#{new_resource.install_dir}/bin/nexus.exe /install nexus3_#{new_resource.instance_name}"
    action :run
    only_if "sc.exe query #{new_resource.instance_name} | find /i \"EnumQueryServicesStatus:OpenService FAILED\""
  end

  windows_service "nexus3_#{new_resource.instance_name}" do
    run_as_user new_resource.nexus3_user
    start_command "#{new_resource.install_dir}/bin/nexus.exe /start nexus3_#{new_resource.instance_name}"
    stop_command "#{new_resource.install_dir}/bin/nexus.exe /stop nexus3_#{new_resource.instance_name}"
    action :enable
  end
end

action :start do
  windows_service "nexus3_#{new_resource.instance_name}" do
    action :start
  end
end

action :restart do
  windows_service "nexus3_#{new_resource.instance_name}" do
    action :restart
  end
end

action :stop do
  windows_service "nexus3_#{new_resource.instance_name}" do
    action :stop
  end
end
