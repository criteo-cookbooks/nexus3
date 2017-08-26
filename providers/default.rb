use_inline_resources

def systype
  return 'systemd' if ::File.exist?('/proc/1/comm') && ::File.open('/proc/1/comm').gets.chomp == 'systemd'
  'sysvinit'
end

# Returns resolved download url, e.g.,
# http://download.sonatype.com/nexus/3/latest-unix.tar.gz ->
# http://download.sonatype.com/nexus/3/nexus-3.0.1-01-unix.tar.gz
def download_url(url)
  uri = URI(url)
  options = { use_ssl: uri.scheme == 'https' }
  response = Net::HTTP.start(uri.host, uri.port, options) { |http| http.get uri.request_uri }

  unless response.is_a?(Net::HTTPRedirection)
    return response['location'].nil? ? url : response['location']
  end

  if response['location'].include?('latest')
    download_url(response['location'])
  else
    response['location']
  end
end

def filename(download_url)
  download_url.slice(download_url.rindex('/') + 1, download_url.size)
end

def version(download_url)
  /(?<=nexus-)(\d\.\d+.\d-.\d)|(?<=nexus-)(\d+.\d-.\d)/.match(download_url).to_s # http://rubular.com/r/kS3DK4zmQb
end

def usr
  new_resource.user.nil? ? 'nexus' : new_resource.user
end

def grp
  if new_resource.group.nil?
    platform?('windows') ? 'Administrators' : 'nexus'
  else
    new_resource.group
  end
end

# inject data path if not provided in vmoptions_variables
def vmoptions(vmoptions = {})
  vmoptions.merge!(new_resource.vmoptions_variables)
  vmoptions['data'] = new_resource.data if vmoptions['data'].nil?
  vmoptions
end

action :install do
  url = download_url(new_resource.url)
  filename = filename(url)
  cached_file = ::File.join(Chef::Config[:file_cache_path], filename)

  user usr do # ~FC021
    comment 'Nexus Repository Manager User'
    shell '/bin/bash'
    password new_resource.password
    home new_resource.home
    system true
    only_if { new_resource.user.nil? }
  end

  group grp do # ~FC021
    members usr
    append true
    only_if { new_resource.group.nil? }
  end

  [new_resource.path, new_resource.data].each do |dir|
    directory dir do
      recursive true
      owner usr
      group grp
    end
  end

  install_dir = "#{new_resource.path}/nexus-#{version(url)}"
  data_dir = new_resource.data.to_s

  remote_file url do
    path cached_file
    source url
    checksum new_resource.checksum unless new_resource.checksum.nil?
    action :create
    not_if { ::File.exist?(install_dir) }
    notifies(:run, "execute[untar #{filename}]", :immediately) unless platform?('windows')
    notifies(:run, "powershell_script[unzip #{filename}]", :immediately) if platform?('windows')
  end

  if platform?('windows')
    powershell_script "unzip #{filename}" do
      code "Add-Type -A 'System.IO.Compression.FileSystem';" \
        " [IO.Compression.ZipFile]::ExtractToDirectory('#{cached_file}', '#{new_resource.path}');"
      action :nothing
      notifies(:run, "batch[install #{new_resource.servicename} service]", :immediately)
    end

    batch "install #{new_resource.servicename} service" do
      code "#{install_dir}/bin/nexus.exe /install"
      action :nothing
      notifies(:restart, "service[#{new_resource.servicename}]")
    end
  else
    execute "untar #{filename}" do
      command "tar -xzf #{cached_file} -C #{new_resource.path} " \
      "&& chown -R #{usr}:#{grp} #{install_dir} #{data_dir}"
      action :nothing
      notifies(:restart, "service[#{new_resource.servicename}]")
    end
  end

  template "#{install_dir}/bin/nexus.rc" do
    source 'nexus.rc.erb'
    cookbook 'nexus3'
    variables(user: usr)
    mode '0644'
    owner usr
    group grp
    notifies(:restart, "service[#{new_resource.servicename}]")
  end

  template "#{install_dir}/bin/nexus.vmoptions" do
    source new_resource.vmoptions_source
    variables vmoptions
    cookbook new_resource.vmoptions_cookbook
    mode '0644'
    owner usr
    group grp
    notifies(:restart, "service[#{new_resource.servicename}]")
  end

  directory "#{data_dir}/etc" do
    owner usr
    group grp
    mode '0755'
    action :create
  end

  template "#{data_dir}/etc/nexus.properties" do
    source new_resource.properties_source
    variables new_resource.properties_variables
    cookbook new_resource.properties_cookbook
    mode '0644'
    owner usr
    group grp
    notifies(:restart, "service[#{new_resource.servicename}]")
  end

  link new_resource.home do
    to install_dir
    owner usr
    group grp
    notifies(:restart, "service[#{new_resource.servicename}]")
  end

  unless platform?('windows')
    case systype
    when 'systemd'
      template "/etc/systemd/system/#{new_resource.servicename}.service" do
        source 'systemd.erb'
        cookbook 'nexus3'
        mode '0755'
        variables(user: usr, home: new_resource.home)
        notifies(:restart, "service[#{new_resource.servicename}]")
      end
    else
      link "/etc/init.d/#{new_resource.servicename}" do
        to "#{new_resource.home}/bin/nexus"
        notifies(:restart, "service[#{new_resource.servicename}]")
      end
    end
  end

  service new_resource.servicename do
    action :enable
  end
end

action :uninstall do
  url = download_url(new_resource.url)
  install_dir = "#{new_resource.path}/nexus-#{version(url)}"

  service new_resource.servicename do # ~FC021
    action %i[stop disable]
    ignore_failure true
    only_if { ::File.exist?(install_dir) }
  end

  execute 'rm -fr nexus-*' do
    cwd Chef::Config[:file_cache_path]
  end

  if platform?('windows')
    batch "uninstall #{new_resource.servicename} service" do
      code "#{new_resource.home}/bin/nexus.exe /uninstall #{new_resource.servicename}"
      only_if { ::File.exist?("#{new_resource.home}/bin/nexus.exe") }
    end
  else
    case systype
    when 'systemd'
      execute "rm -fr /etc/systemd/system/#{new_resource.servicename}.service" do
        only_if { ::File.exist?("/etc/systemd/system/#{new_resource.servicename}.service") }
      end
    else
      execute "rm -fr /etc/init.d/#{new_resource.servicename}" do
        only_if { ::File.exist?("/etc/init.d/#{new_resource.servicename}") }
      end
    end
  end

  execute "rm -fr #{install_dir} #{new_resource.home}" do
    only_if { ::File.exist?(install_dir) }
  end
end
