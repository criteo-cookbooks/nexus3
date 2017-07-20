property :instance_name, kind_of: String, name_attribute: true
property :nexus3_user, kind_of: [String, NilClass], default: lazy { node['nexus3']['user'] }
property :nexus3_group, kind_of: [String, NilClass], default: lazy { node['nexus3']['group'] }
# property :nexus3_password, kind_of: [String, NilClass], sensitive: true # Admin password
property :version, kind_of: String, default: lazy { node['nexus3']['version'] }
property :url, kind_of: String, default: lazy { node['nexus3']['url'] }
property :checksum, kind_of: String, default: lazy { node['nexus3']['checksum'] }
property :nexus3_home, kind_of: String, default: lazy { node['nexus3']['home'] }
property :path, kind_of: String, default: lazy { node['nexus3']['path'] }
property :data, kind_of: String, default: lazy { node['nexus3']['data'] }
property :properties_variables, kind_of: Hash, default: lazy { node['nexus3']['properties_variables'] }
property :vmoptions_variables, kind_of: Hash, default: lazy { node['nexus3']['vmoptions_variables'] }

load_current_value do
  # TODO: check if user, group, etc. exist for each property or so. But: do we need to do so?
end

# TODO: use helpers to make this section smaller?
action :install do
  install_dir = ::File.join(path, "nexus-#{version}")

  user new_resource.nexus3_user do
    comment 'Nexus 3 user'
    home nexus3_home
    manage_home false # is linked to install_dir below
    shell '/bin/bash'
  end

  group new_resource.nexus3_group do
    members nexus3_user
    append true
  end

  # Install Nexus3 software
  ark "nexus-#{new_resource.version}" do
    action :put
    url download_url
    checksum new_resource.checksum
    path new_resource.path
    owner new_resource.nexus3_user
    group new_resource.nexus3_group
  end

  # Setup directories
  [install_dir, data, ::File.join(data, 'etc')].each do |dir|
    directory dir do
      recursive true
      owner nexus3_user
      group nexus3_group
      mode '0755'
    end
  end

  # Install configuration from templates
  template ::File.join(install_dir, 'bin', 'nexus.rc') do
    source 'nexus.rc.erb'
    variables(user: nexus3_user)
    mode '0644'
    owner nexus3_user
    group nexus3_group
    cookbook 'nexus3'
    notifies :restart, "nexus3_service[nexus3_#{new_resource.instance_name}]", :delayed
    notifies :create, 'ruby_block[block until operational]', :delayed
  end

  template ::File.join(install_dir, 'bin', 'nexus.vmoptions') do
    source 'nexus.vmoptions.erb'
    variables(
      vmoptions_variables.merge(data: new_resource.data)
    )
    mode '0644'
    owner nexus3_user
    group nexus3_group
    cookbook 'nexus3'
    notifies :restart, "nexus3_service[nexus3_#{new_resource.instance_name}]", :delayed
    notifies :create, 'ruby_block[block until operational]', :delayed
  end

  template ::File.join(data, 'etc', 'nexus.properties') do
    source 'nexus.properties.erb'
    variables properties_variables
    mode '0644'
    user nexus3_user
    group nexus3_group
    cookbook 'nexus3'
    notifies :restart, "nexus3_service[nexus3_#{new_resource.instance_name}]", :delayed
    notifies :create, 'ruby_block[block until operational]', :delayed
  end

  link nexus3_home do
    to install_dir
    owner nexus3_user
    group nexus3_group
  end

  nexus3_service "nexus3_#{new_resource.instance_name}" do
    install_dir install_dir
    nexus3_user new_resource.nexus3_user
    nexus3_group new_resource.nexus3_group
    action :enable
  end

  # Allow for Nexus to fully start before moving on.
  ruby_block 'block until operational' do
    block do
      Chef::Log.info "Waiting until Nexus is listening on port #{node['nexus3']['properties_variables']['port']}"
      wait_until_ready!(node['nexus3']['api']['endpoint'])
    end
    action :nothing
  end
end

action_class do
  def download_url
    return node['nexus3']['url'] unless node['nexus3']['url'].nil? || node['nexus3']['url'].empty?
    url = 'https://download.sonatype.com/nexus/3/nexus-'
    url << new_resource.version.to_s
    url << if platform?('windows')
             '-win64.zip'
           else
             '-unix.tar.gz'
           end
    url
  end

  include Nexus3::Helper
end
