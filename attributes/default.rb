if platform?('windows')
  default['nexus3']['path'] = 'C:\Nexus3'
  default['nexus3']['group'] = 'Administrators'
else
  default['nexus3']['path'] = '/opt'
  default['nexus3']['group'] = 'nexus'
end
# Download URL is defined in the resource but you can override it with the default['nexus3']['url'] attribute
default['nexus3']['version'] = '3.64.0-04'
default['nexus3']['url'] = nil # optional
default['nexus3']['checksum'] = nil # optional
default['nexus3']['home'] = "#{node['nexus3']['path']}/nexus3"
default['nexus3']['data'] = "#{node['nexus3']['path']}/sonatype-work/nexus3"
# Nexus username (do not run as root)
default['nexus3']['user'] = 'nexus'
default['nexus3']['uid'] = nil
default['nexus3']['gid'] = nil
# Additional groups to add nexus user to, for example when sharing a license file between users.
# Groups listed must already exist.
default['nexus3']['additional_groups'] = []

default['nexus3']['properties_variables']['application-port'] = '8081'
default['nexus3']['properties_variables']['application-host'] = '0.0.0.0'
default['nexus3']['properties_variables']['nexus-args'] = '${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-requestlog.xml'
default['nexus3']['properties_variables']['nexus-context-path'] = '/'
default['nexus3']['properties_variables']['nexus.scripts.allowCreation'] = 'true'

default['nexus3']['logback_variables'] = {}

default['nexus3']['nofile_limit'] = 65_536

# Nexus JVM tunning
# Ref:
#   https://help.sonatype.com/repomanager3/installation/configuring-the-runtime-environment
#   https://help.sonatype.com/repomanager3/system-requirements
default['nexus3']['desired_heap_size'] = '4G'

on_attribute_update('nexus3', 'desired_heap_size') do |_precedence, _path, new_value, previous_value|
  new_value ||= node.read('nexus3', 'desired_heap_size') # the block is yield on registration with no "new value"

  rm_default('nexus3', 'vmoptions_variables', "Xms#{previous_value}")
  rm_default('nexus3', 'vmoptions_variables', "Xmx#{previous_value}")
  default['nexus3']['vmoptions_variables']["Xms#{new_value}"] = nil
  default['nexus3']['vmoptions_variables']["Xmx#{new_value}"] = nil
end

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
default['nexus3']['vmoptions_variables']['Djava.endorsed.dirs'] = 'lib/endorsed'

# Plugins bundles in KAR format to install
#
#  default['nexus3']['plugins']['nexus-repository-chef'] = {
#    "name": "force_another_name",
#    "source": "https://on.the.internet/nexus-repository-chef-0.0.10-bundle.kar",
#    "checksum": "8e6494bd8edbf3beb6b7054d599561e698dcf3f666c2114b7126c246804484a9",
#    "action": "create" # https://docs.chef.io/resources/remote_file/#actions
#  }
#
# https://help.sonatype.com/en/installing-bundles.html
default['nexus3']['plugins'] = {}
