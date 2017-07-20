provides :nexus3_service_systemd

provides :nexus3_service, os: 'linux' do |_node|
  ::Chef::Platform::ServiceHelpers.service_resource_providers.include?(:systemd)
end

property :instance_name, String, name_property: true
property :install_dir, String
property :nexus3_user, String
property :nexus3_group, String

action :start do
  create_init

  service "nexus3_#{new_resource.instance_name}" do
    service_name "nexus3@#{new_resource.instance_name}"
    supports restart: true, status: true
    action :start
    only_if 'command -v java >/dev/null 2>&1 || exit 1'
  end
end

action :stop do
  service "nexus3_#{new_resource.instance_name}" do
    service_name "nexus3@#{new_resource.instance_name}"
    supports status: true
    action :stop
  end
end

action :restart do
  service "nexus3_#{new_resource.instance_name}" do
    service_name "nexus3@#{new_resource.instance_name}"
    supports status: true
    action :restart
  end
end

action :disable do
  service "nexus3_#{new_resource.instance_name}" do
    service_name "nexus3@#{new_resource.instance_name}"
    supports status: true
    action :disable
  end
end

action :enable do
  create_init

  service "nexus3_#{new_resource.instance_name}" do
    service_name "nexus3@#{new_resource.instance_name}"
    supports status: true
    action :enable
  end
end

action_class do
  def create_init
    # TODO: create /etc/nexus3 dir, use instance_name.env template, use systemd service "instance"
    # TODO: Use https://coreos.com/os/docs/latest/using-environment-variables-in-systemd-units.html
    # create cookbook_file /etc/systemd/system/nexus3@.service
    # TODO: template /etc/nexus3/%i.env with INSTALL_DIR, NEXUS3_USER
    directory '/etc/nexus3' do
      owner new_resource.nexus3_user
      group new_resource.nexus3_group
      mode '0755'
    end

    cookbook_file '/etc/systemd/system/nexus3@.service' do
      source 'nexus3@.service'
      cookbook 'nexus3'
      notifies :run, 'execute[Load systemd unit file]', :immediately
    end

    template "/etc/nexus3/#{new_resource.instance_name}.env" do
      source 'systemd_instance_env.erb'
      variables(
        install_dir: install_dir,
        nexus3_user: new_resource.nexus3_user
      )
      cookbook 'nexus3'
      notifies :restart, "service[nexus3_#{new_resource.instance_name}]"
    end

    execute 'Load systemd unit file' do
      command 'systemctl daemon-reload'
      action :nothing
    end
  end
end
