if platform?('windows')
  default['nexus3']['url'] = 'http://download.sonatype.com/nexus/3/latest-win64.zip'
  default['nexus3']['data'] = "#{ENV['SYSTEMDRIVE']}/repository/data"
  default['nexus3']['path'] = "#{ENV['SYSTEMDRIVE']}/sonatype"
else
  default['nexus3']['url'] = 'http://download.sonatype.com/nexus/3/latest-unix.tar.gz'
  default['nexus3']['data'] = '/opt/repository/data'
  default['nexus3']['path'] = '/opt/sonatype'
end
default['nexus3']['checksum'] = nil # optional
default['nexus3']['home'] = "#{node['nexus3']['path']}/nexus"

default['nexus3']['cfg_cookbook'] = 'nexus3'
default['nexus3']['cfg_source'] = 'org.sonatype.nexus.cfg.erb'
default['nexus3']['cfg_variables'] = {
  host: '0.0.0.0',
  port: '8081',
  context_path: '/'
}

default['nexus3']['vmoptions_cookbook'] = 'nexus3'
default['nexus3']['vmoptions_source'] = 'nexus.vmoptions.erb'
default['nexus3']['vmoptions_variables'] = {
  Xms: '1200M',
  Xmx: '1200M'
}
