property :instance_name, String, name_property: true
property :nexus3_user, [String, NilClass], default: lazy { node['nexus3']['user'] }
property :nexus3_uid, [String, Integer, NilClass], default: lazy { node['nexus3']['uid'] }
property :nexus3_group, [String, NilClass], default: lazy { node['nexus3']['group'] }
property :nexus3_gid, [String, Integer, NilClass], default: lazy { node['nexus3']['gid'] }
property :nexus3_additional_groups, [Array, NilClass], default: lazy { node['nexus3']['additional_groups'] }
property :nexus3_password, String, sensitive: true, default: lazy { node['nexus3']['api']['password'] } # Admin password
property :version, String, default: lazy { node['nexus3']['version'] }
property :url, [String, NilClass], default: lazy { node['nexus3']['url'] }
property :checksum, [String, NilClass], default: lazy { node['nexus3']['checksum'] }
property :nexus3_home, String, default: lazy { node['nexus3']['home'] }
property :path, String, default: lazy { node['nexus3']['path'] }
property :data, String, default: lazy { node['nexus3']['data'] }
# Name of service used as property for nexus3_service; can be instance_name or something different
# like version number.
property :service_name, String, default: lazy { instance_name }
property :properties_variables, Hash, default: lazy { node['nexus3']['properties_variables'] }
property :vmoptions_variables, Hash, default: lazy { node['nexus3']['vmoptions_variables'] }
property :outbound_proxy, [Hash, NilClass], sensitive: true, default: lazy { node['nexus3']['outbound_proxy'] }
property :plugins, Hash, default: lazy { node['nexus3']['plugins'] }

action :install do
  install_dir = ::File.join(new_resource.path, "nexus-#{new_resource.version}")

  group new_resource.nexus3_group do
    gid new_resource.nexus3_gid unless new_resource.nexus3_gid.nil?
  end

  user new_resource.nexus3_user do
    comment 'Nexus 3 user'
    group new_resource.nexus3_group
    home new_resource.nexus3_home
    manage_home false # is linked to install_dir below
    shell '/bin/bash'
    uid new_resource.nexus3_uid unless new_resource.nexus3_uid.nil?
  end

  new_resource.nexus3_additional_groups.to_a.each do |gr|
    group "add #{new_resource.nexus3_user} user to #{gr} group" do
      group_name gr
      action :modify
      append true
      members [new_resource.nexus3_user]
      not_if { platform?('windows') }
    end
  end

  # Install Nexus3 software
  ark "nexus-#{new_resource.version}" do
    action :put
    url download_url
    checksum new_resource.checksum unless new_resource.checksum.nil?
    path new_resource.path
    owner new_resource.nexus3_user
    group new_resource.nexus3_group
  end

  # Setup directories
  [install_dir, new_resource.data, ::File.join(new_resource.data, 'etc')].each do |dir|
    directory dir do
      recursive true
      owner new_resource.nexus3_user
      group new_resource.nexus3_group
      mode '0755'
    end
  end

  port = new_resource.properties_variables['application-port']
  blocker = "block until Nexus #{new_resource.service_name}@#{port} operational"

  # Install configuration from templates
  template ::File.join(install_dir, 'bin', 'nexus.rc') do
    source 'nexus.rc.erb'
    variables(user: new_resource.nexus3_user)
    mode '0644'
    owner new_resource.nexus3_user
    group new_resource.nexus3_group
    cookbook 'nexus3'
    notifies :restart, "nexus3_service[#{new_resource.service_name}]", :delayed
    notifies :run, "ruby_block[#{blocker}]", :delayed
  end

  vars = new_resource.vmoptions_variables.dup

  vars['XX:LogFile'] ||= ::File.join(new_resource.data, 'log', 'jvm.log')
  vars['Dkaraf.data'] ||= new_resource.data
  vars['Djava.io.tmpdir'] ||= ::File.join(new_resource.data, 'tmp')

  vmoptions = vars.map do |k, v|
    v.nil? ? "-#{k}\n" : "-#{k}=#{v}\n"
  end

  file ::File.join(install_dir, 'bin', 'nexus.vmoptions') do
    owner new_resource.nexus3_user
    group new_resource.nexus3_group
    mode '0644'
    content vmoptions.join
    notifies :restart, "nexus3_service[#{new_resource.service_name}]", :delayed
    notifies :run, "ruby_block[#{blocker}]", :delayed
  end

  file ::File.join(new_resource.data, 'etc', 'nexus.properties') do
    content new_resource.properties_variables.map { |k, v| "#{k}=#{v}" }.join("\n")
    mode '0644'
    user new_resource.nexus3_user
    group new_resource.nexus3_group
    notifies :restart, "nexus3_service[#{new_resource.service_name}]", :delayed
    notifies :run, "ruby_block[#{blocker}]", :delayed
  end

  # Install plugins
  new_resource.plugins.each do |name, config|
    plugin_file_path = ::File.join(install_dir, 'deploy', "#{config['name'] || name}-bundle.kar")
    remote_file plugin_file_path do
      source config['source']
      checksum config['checksum']
      owner new_resource.nexus3_user
      action((config['action'] || :create).to_sym)
      notifies :restart, "nexus3_service[#{new_resource.service_name}]", :delayed
      notifies :run, "ruby_block[#{blocker}]", :delayed
    end
  end

  link new_resource.nexus3_home do
    to install_dir
    owner new_resource.nexus3_user
    group new_resource.nexus3_group
  end

  nexus3_service new_resource.service_name.to_s do
    install_dir install_dir
    nexus3_user new_resource.nexus3_user
    nexus3_group new_resource.nexus3_group
    action :enable
  end

  pwchanger = "admin_change_password for #{new_resource.service_name}@#{port}"

  # Allow for Nexus to fully start before moving on.
  ruby_block blocker do
    block do
      Chef::Log.info "Waiting until Nexus #{new_resource.service_name} is listening on port #{port}"
      wait_until_ready!(::Nexus3::Api.endpoint(port), node['nexus3']['api']['wait'])
    end
    action :nothing
    notifies :create, "nexus3_api[#{pwchanger}]"
    notifies :run, "nexus3_api[#{pwchanger}]"
    notifies new_resource.outbound_proxy ? :create : :delete, 'nexus3_outbound_proxy[default]'
  end

  passwd_file = ::File.join(new_resource.data, 'admin.password')

  nexus3_api pwchanger do
    script_name 'change_admin_password'
    content "security.securitySystem.changePassword('admin', args)"
    args new_resource.nexus3_password
    api_client(lazy { ::Nexus3::Api.local(port, 'admin', ::File.read(passwd_file)) })
    only_if { ::File.exist? passwd_file }
    action :nothing
    notifies :delete, "file[#{passwd_file}]"
  end

  file passwd_file do
    action :nothing
  end

  # Configure outbound proxy (triggered after password changed)
  nexus3_outbound_proxy 'default' do
    action :nothing
    config new_resource.outbound_proxy unless new_resource.outbound_proxy.nil?
    api_client(lazy { ::Nexus3::Api.local(port, 'admin', new_resource.nexus3_password) })
  end
end

action_class do
  def download_url
    return new_resource.url unless new_resource.url.nil? || new_resource.url.empty?

    url = 'https://download.sonatype.com/nexus/3/nexus-'
    url << new_resource.version.to_s
    url << if platform?('windows')
             '-win64.zip'
           else
             '-unix.tar.gz'
           end
    url
  end

  include ::Nexus3::Helper
end
