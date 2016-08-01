use_inline_resources

def whyrun_supported?
  true
end

def systype
  return 'systemd' if ::File.exist?('/proc/1/comm') && ::File.open('/proc/1/comm').gets.chomp == 'systemd'
  'sysvinit'
end

# Returns resolved download url, e.g.,
# http://download.sonatype.com/nexus/3/latest-unix.tar.gz ->
# http://download.sonatype.com/nexus/3/nexus-3.0.1-01-unix.tar.gz
def download_url(url)
  uri = URI(url)
  response = Net::HTTP.start(uri.host) { |http| http.get uri.request_uri }

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
  /\d\.\d+.\d-.\d|\d+.\d-.\d/.match(download_url).to_s # http://rubular.com/r/xutlWB31fR
end

action :install do
  converge_by('install nexus') do
    url = download_url(new_resource.url)
    filename = filename(url)
    cached_file = ::File.join(Chef::Config[:file_cache_path], filename)
    usr = new_resource.user.nil? ? 'nexus' : new_resource.user
    grp = new_resource.group.nil? ? 'nexus' : new_resource.group

    group grp do # ~FC021
      system true
      only_if { new_resource.group.nil? }
    end

    user usr do # ~FC021
      home new_resource.root
      shell '/bin/bash'
      gid grp
      system true
      only_if { new_resource.user.nil? }
    end

    [new_resource.root, new_resource.data].each do |dir|
      directory dir do
        recursive true
        owner usr
        group grp
      end
    end

    install_dir = "#{new_resource.root}/nexus-#{version(url)}"

    remote_file url do
      path cached_file
      source url
      checksum new_resource.checksum unless new_resource.checksum.nil?
      action :create
      not_if { ::File.exist?(install_dir) }
      notifies(:run, 'execute[untar nexus]', :immediately)
    end

    execute 'untar nexus' do
      command "tar -xzf #{cached_file} -C #{new_resource.root} " \
        "&& chown -R #{usr}:#{grp} #{new_resource.root}"
      action :nothing
      notifies(:restart, "service[#{new_resource.servicename}]")
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

    template "#{install_dir}/etc/org.sonatype.nexus.cfg" do
      source new_resource.cfg_source
      variables new_resource.cfg_variables
      cookbook new_resource.cfg_cookbook
      mode '0644'
      owner usr
      group grp
      notifies(:restart, "service[#{new_resource.servicename}]")
    end

    file "#{install_dir}/bin/nexus.vmoptions" do
      content new_resource.vmoptions.join("\n")
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

    service new_resource.servicename do
      action :enable
    end
  end
end
