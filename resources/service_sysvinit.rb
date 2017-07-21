provides :nexus3_service_sysvinit
provides :nexus3_service, os: 'linux'

property :instance_name, String, name_property: true
property :install_dir, String
property :nexus3_user, String
property :nexus3_group, String

action :start do
  create_init

  service "nexus3_#{new_resource.instance_name}" do
    supports restart: true, status: true
    action :start
  end
end

action :stop do
  service "nexus3_#{new_resource.instance_name}" do
    supports status: true
    action :stop
  end
end

action :restart do
  service "nexus3_#{new_resource.instance_name}" do
    supports status: true
    action :restart
  end
end

action :enable do
  create_init

  service "nexus3_#{new_resource.instance_name}" do
    supports status: true
    action :enable
  end
end

action :disable do
  service "nexus3_#{new_resource.instance_name}" do
    supports status: true
    action :disable
  end
end

action_class do
  def create_init
    link ::File.join('/etc/init.d', "nexus3_#{new_resource.instance_name}") do
      to ::File.join(new_resource.install_dir.to_s, 'bin', 'nexus')
      owner new_resource.nexus3_user
      group new_resource.nexus3_group
    end
  end

  def platform_sysv_init_class
    value_for_platform_family(
      'debian' => Chef::Provider::Service::Init::Debian,
      'default' => Chef::Provider::Service::Init::Redhat
    )
  end
end
