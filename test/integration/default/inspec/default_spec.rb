require_relative 'inspec_helper'

title 'nexus::default'

if os[:family] == 'windows'
  describe file('C:/sonatype-work/nexus3') do
    it { should be_owned_by 'nexus' }
  end

  describe file('C:/sonatype-work/nexus3/etc') do
    it { should be_directory }
    it { should be_owned_by 'nexus' }
  end

  describe service('nexus3_foo') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('C:/sonatype-work/nexus3/etc/nexus.properties') do
    it { should be_file }
    it { should be_owned_by 'nexus' }
    its('content') { should match('application-port=8081') }
    its('content') { should match('application-host=0.0.0.0') }
    its('content') { should match(%r{nexus-args=\$\{jetty.etc\}/jetty.xml,\$\{jetty.etc\}/jetty-http.xml,\$\{jetty.etc\}/jetty-requestlog.xml}) }
    its('content') { should match(%r{nexus-context-path=/}) }
  end

  ping = <<~PING_COMMAND
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f 'admin','admin123'))); \
    Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} \
    -URI http://localhost:8081/service/metrics/ping
  PING_COMMAND

  describe command("powershell -command { #{ping.strip} }") do
    its(:stdout) { should match('pong') }
  end
else # Linux
  describe file('/opt/sonatype-work/nexus3') do
    it { should be_directory }
    it { should be_owned_by 'nexus' }
  end

  describe file('/opt/nexus3') do
    it { should be_symlink }
    it { should be_owned_by 'nexus' }
  end

  describe file('/opt/sonatype-work/nexus3/etc') do
    it { should be_directory }
    it { should be_owned_by 'nexus' }
  end

  describe file('/opt/sonatype-work/nexus3/etc/nexus.properties') do
    it { should be_file }
    it { should be_owned_by 'nexus' }
    its('content') { should match('application-port=8081') }
    its('content') { should match('application-host=0.0.0.0') }
    its('content') { should match(%r{nexus-args=\$\{jetty.etc\}/jetty.xml,\$\{jetty.etc\}/jetty-http.xml,\$\{jetty.etc\}/jetty-requestlog.xml}) }
    its('content') { should match(%r{nexus-context-path=/}) }
  end

  describe file('/opt/nexus3/deploy/nexus-repository-cargo-bundle.kar') do
    it { should be_file }
    it { should be_owned_by 'nexus' }
  end

  describe user('nexusbar') do
    it { should exist }
    its('uid') { should eq 1234 }
    its('group') { should eq 'nexusbar' }
    its('gid') { should eq 5678 }
  end

  describe file('/usr/local/nexusbar/data/etc') do
    it { should be_directory }
    it { should be_owned_by 'nexusbar' }
  end

  %w[foo bar].each do |service|
    unless os.debian? || os.linux?
      describe service("nexus3_#{service}") do
        it { should be_enabled }
      end
    end

    next if os.linux?

    describe service("nexus3_#{service}") do
      it { should be_running }
    end
  end

  [{ port: 8081, password: 'admin123' }, { port: 8082, password: 'humdiddle' }].each do |cfg|
    describe port(cfg[:port]) do
      it { should be_listening }
      its('protocols') { should include('tcp') }
    end

    describe command("curl -u admin:#{cfg[:password]} http://localhost:#{cfg[:port]}/service/metrics/ping") do
      its(:stdout) { should match('pong') }
    end
  end
end
