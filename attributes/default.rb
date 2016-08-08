if platform?('windows')
  default['nexus3']['url'] = 'http://download.sonatype.com/nexus/3/latest-win64.zip'
  default['nexus3']['data'] = "#{ENV['SYSTEMDRIVE']}/repository/data"
  default['nexus3']['root'] = "#{ENV['SYSTEMDRIVE']}/sonatype"
else
  default['nexus3']['url'] = 'http://download.sonatype.com/nexus/3/latest-unix.tar.gz'
  default['nexus3']['data'] = '/opt/repository/data'
  default['nexus3']['root'] = '/opt/sonatype'
end
default['nexus3']['checksum'] = nil # optional
default['nexus3']['home'] = "#{node['nexus3']['root']}/nexus"
default['nexus3']['cfg_cookbook'] = 'nexus3'
default['nexus3']['cfg_source'] = 'org.sonatype.nexus.cfg.erb'
default['nexus3']['cfg_variables'] = {
  port: '8081',
  context_path: '/'
}
default['nexus3']['vmoptions'] = [
  '-Xms1200M',
  '-Xmx1200M',
  '-XX:+UnlockDiagnosticVMOptions',
  '-XX:+UnsyncloadClass',
  '-Djava.net.preferIPv4Stack=true',
  '-Dkaraf.home=.',
  '-Dkaraf.base=.',
  '-Dkaraf.etc=etc',
  '-Djava.util.logging.config.file=etc/java.util.logging.properties',
  "-Dkaraf.data=#{node['nexus3']['data']}",
  "-Djava.io.tmpdir=#{node['nexus3']['data']}/tmp",
  '-Dkaraf.startLocalConsole=false'
]
