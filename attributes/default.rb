if platform?('windows')
  default['nexus3']['url'] = 'http://download.sonatype.com/nexus/3/latest-win64.zip'
  default['nexus3']['path'] = ENV['SYSTEMDRIVE']
else
  default['nexus3']['url'] = 'http://download.sonatype.com/nexus/3/latest-unix.tar.gz'
  default['nexus3']['path'] = '/opt'
end
default['nexus3']['checksum'] = nil # optional
default['nexus3']['home'] = "#{node['nexus3']['path']}/nexus3"
default['nexus3']['data'] = "#{node['nexus3']['path']}/sonatype-work/nexus3"

default['nexus3']['properties_cookbook'] = 'nexus3'
default['nexus3']['properties_source'] = 'nexus.properties.erb'
default['nexus3']['properties_variables'] = {
  host: '0.0.0.0',
  port: '8081',
  args: '${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-requestlog.xml',
  context_path: '/'
}

default['nexus3']['vmoptions_cookbook'] = 'nexus3'
default['nexus3']['vmoptions_source'] = 'nexus.vmoptions.erb'
default['nexus3']['vmoptions_variables'] = {
  Xms: '1200M',
  Xmx: '1200M'
}
