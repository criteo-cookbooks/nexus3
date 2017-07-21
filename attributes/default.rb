if platform?('windows')
  default['nexus3']['path'] = 'C:\Nexus3'
  default['nexus3']['group'] = 'Administrators'
else
  default['nexus3']['path'] = '/opt'
  default['nexus3']['group'] = 'nexus'
end
# Download URL is defined in the resource but you can override it with the default['nexus3']['url'] attribute
default['nexus3']['url'] = 'https://download.sonatype.com/nexus/3/nexus-3.2.1-01-unix.tar.gz'
default['nexus3']['checksum'] = nil # optional
default['nexus3']['home'] = "#{node['nexus3']['path']}/nexus3"
default['nexus3']['data'] = "#{node['nexus3']['path']}/sonatype-work/nexus3"
# Nexus username (do not run as root)
default['nexus3']['user'] = 'nexus'

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
