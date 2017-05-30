default['nexus3']['version'] = '3.3.1-01'
if platform?('windows')
  default['nexus3']['url'] = "https://download.sonatype.com/nexus/3/nexus-#{node['nexus3']['version']}-win64.zip"
  default['nexus3']['path'] = ENV['SYSTEMDRIVE']
else
  default['nexus3']['url'] = "https://download.sonatype.com/nexus/3/nexus-#{node['nexus3']['version']}-unix.tar.gz"
  default['nexus3']['path'] = '/opt'
end
default['nexus3']['checksum'] = nil # optional
default['nexus3']['home'] = "#{node['nexus3']['path']}/nexus3"
default['nexus3']['data'] = "#{node['nexus3']['path']}/sonatype-work/nexus3"
default['nexus3']['user'] = 'nexus'
default['nexus3']['group'] = 'nexus'

default['nexus3']['properties_variables'] = {
  host: '0.0.0.0',
  port: '8081',
  args: '${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-requestlog.xml',
  context_path: '/'
}

default['nexus3']['vmoptions_variables'] = {
  Xms: '1200M',
  Xmx: '1200M'
}
