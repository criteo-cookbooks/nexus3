provides :nexus3_service_sysvinit
provides :nexus3_service, os: 'linux'

property :instance_name, String, name_property: true
property :install_dir, String
property :nexus3_user, String
property :nexus3_group, String

# TODO: easy
# http://www.sonatype.org/nexus/2017/01/25/how-to-install-latest-sonatype-nexus-3-on-linux/
# sudo ln -s /app/nexus/bin/nexus /etc/init.d/nexus
# sudo chkconfig --add nexus
# sudo chkconfig --levels 345 nexus on

action :start do
  create_init

  service "nexus3_#{new_resource.instance_name}" do
    # TODO: define in helper (see Tomcat)
    provider platform_sysv_init_class
    supports restart: true, status: true
    action :start
  end
end

action :stop do
  service "nexus3_#{new_resource.instance_name}" do
    provider platform_sysv_init_class
    supports status: true
    action :stop
    only_if { ::File.exist?("/etc/init.d/nexus3_#{new_resource.instance_name}") }
  end
end

action :restart do
  service "nexus3_#{new_resource.instance_name}" do
    provider platform_sysv_init_class
    supports status: true
    action :restart
  end
end

action :enable do
  create_init

  service "nexus3_#{new_resource.instance_name}" do
    provider platform_sysv_init_class
    supports status: true
    action :enable
    only_if { ::File.exist?("/etc/init.d/nexus3_#{new_resource.instance_name}") }
  end
end

action :disable do
  service "nexus3_#{new_resource.instance_name}" do
    provider platform_sysv_init_class
    supports status: true
    action :disable
    only_if { ::File.exist?("/etc/init.d/nexus3_#{new_resource.instance_name}") }
  end
end

action_class do
  def create_init
    link ::File.join('/etc/init.d', "nexus3_#{new_resource.instance_name}") do
      to ::File.join(new_resource.install_dir.to_s, 'bin', 'nexus')
      owner new_resource.nexus3_user
      group new_resource.nexus3_group
    end

    if platform_family?('rhel', 'fedora')
      execute 'chkconfig add' do
        command "chkconfig --add nexus3_#{new_resource.instance_name}"
      end

      execute 'chkconfig levels' do
        command "chkconfig --levels 345 nexus3_#{new_resource.instance_name} on"
      end
    else
      execute 'update-rc.d' do
        command "update-rc.d nexus3_#{new_resource.instance_name} defaults"
      end
    end
  end

  def platform_sysv_init_class
    value_for_platform_family(
      'debian' => Chef::Provider::Service::Init::Debian,
      'default' => Chef::Provider::Service::Init::Redhat
    )
  end
end
