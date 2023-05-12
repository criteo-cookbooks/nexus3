provides :nexus3_service_systemd

provides :nexus3_service, os: 'linux' do |_node|
  ::Chef::Platform::ServiceHelpers.service_resource_providers.include?(:systemd)
end

property :instance_name, String, name_property: true
property :install_dir, String
property :nexus3_user, String
property :nexus3_group, String
property :nofile_limit, Integer, default: lazy { node['nexus3']['nofile_limit'] }

action :start do
  create_init

  service "nexus3_#{new_resource.instance_name}" do
    supports restart: true, status: true
    action :start
    only_if 'command -v java >/dev/null 2>&1 || exit 1'
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

action :disable do
  service "nexus3_#{new_resource.instance_name}" do
    supports status: true
    action :disable
  end
end

action :enable do
  create_init

  service "nexus3_#{new_resource.instance_name}" do
    supports status: true
    action :enable
  end
end

action_class do
  def create_init
    nexus_bin = ::File.join(new_resource.install_dir, 'bin', 'nexus')
    systemd_unit "nexus3_#{new_resource.instance_name}.service" do
      action :create
      content(
        Unit: {
          Description: "nexus service (#{new_resource.instance_name})",
          After: 'network.target'
        },
        Service: {
          Type: 'forking',
          LimitNOFILE: new_resource.nofile_limit,
          ExecStart: "#{nexus_bin} start",
          ExecStop: "#{nexus_bin} stop",
          User: new_resource.nexus3_user,
          Restart: 'on-abort'
        },
        Install: {
          WantedBy: 'multi-user.target'
        }
      )
    end
  end
end
