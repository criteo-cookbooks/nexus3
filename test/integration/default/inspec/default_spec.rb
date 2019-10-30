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

  ping = <<-EOF
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f 'admin','admin123'))); \
Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} \
-URI http://localhost:8081/service/metrics/ping
EOF

  describe command("powershell -command { #{ping.strip} }") do
    its(:stdout) { should match('pong') }
  end

  script_foo = <<-EOH
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f 'admin','admin123'))); \
Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} \
-URI http://localhost:8081/service/rest/v1/script/foo -Method GET
EOH

  describe command("powershell -command { #{script_foo.strip} }") do
    its(:stdout) { should match(/name.*content.*type/) }
    its(:stdout) { should match(/foo.*repository.createMaven.*groovy/) }
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

  describe file('/usr/local/nexusbar/data/etc') do
    it { should be_directory }
    it { should be_owned_by 'nexusbar' }
  end

  %w(foo bar).each do |service|
    unless os.debian?
      describe service("nexus3_#{service}") do
        it { should be_enabled }
      end
    end

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

    describe command("curl -u admin:#{cfg[:password]} http://localhost:#{cfg[:port]}/service/rest/v1/script/foo") do
      its(:stdout) { should match(/name.*foo/) }
      its(:stdout) { should match(/content.*repository.createMavenHosted.*foo/) }
      its(:stdout) { should match(/type.*groovy/) }
    end
  end
end
