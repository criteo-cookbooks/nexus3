if platform?('windows')
  default['nexus3']['path'] = 'C:\Nexus3'
  default['nexus3']['group'] = 'Administrators'
else
  default['nexus3']['path'] = '/opt'
  default['nexus3']['group'] = 'nexus'
end
# Download URL is defined in the resource but you can override it with the default['nexus3']['url'] attribute
default['nexus3']['version'] = '3.27.0-03'
default['nexus3']['url'] = nil # optional
default['nexus3']['checksum'] = nil # optional
default['nexus3']['home'] = "#{node['nexus3']['path']}/nexus3"
default['nexus3']['data'] = "#{node['nexus3']['path']}/sonatype-work/nexus3"
# Nexus username (do not run as root)
default['nexus3']['user'] = 'nexus'

default['nexus3']['properties_variables']['application-port'] = '8081'
default['nexus3']['properties_variables']['application-host'] = '0.0.0.0'
default['nexus3']['properties_variables']['nexus-args'] = '${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-requestlog.xml'
default['nexus3']['properties_variables']['nexus-context-path'] = '/'
default['nexus3']['properties_variables']['nexus.scripts.allowCreation'] = 'true'

default['nexus3']['nofile_limit'] = 65_536

# Nexus JVM tunning
# Ref:
#   https://help.sonatype.com/repomanager3/installation/configuring-the-runtime-environment
#   https://help.sonatype.com/repomanager3/system-requirements
default['nexus3']['vmoptions_variables']['Xms4G'] = nil
default['nexus3']['vmoptions_variables']['Xmx4G'] = nil
default['nexus3']['vmoptions_variables']['XX:+HeapDumpOnOutOfMemoryError'] = nil
default['nexus3']['vmoptions_variables']['XX:+UnlockDiagnosticVMOptions'] = nil
default['nexus3']['vmoptions_variables']['XX:+UnsyncloadClass'] = nil
default['nexus3']['vmoptions_variables']['XX:+LogVMOutput'] = nil
default['nexus3']['vmoptions_variables']['XX:MaxDirectMemorySize'] = '39158M'
default['nexus3']['vmoptions_variables']['Dkaraf.etc'] = 'etc/karaf'
default['nexus3']['vmoptions_variables']['Dkaraf.base'] = '.'
default['nexus3']['vmoptions_variables']['Dkaraf.home'] = '.'
default['nexus3']['vmoptions_variables']['Dkaraf.startLocalConsole'] = false
default['nexus3']['vmoptions_variables']['Djava.net.preferIPv4Stack'] = true
