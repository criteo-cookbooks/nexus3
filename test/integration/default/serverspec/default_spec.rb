require 'serverspec_helper'

describe 'nexus::default' do
  if os[:family] == 'windows'
    describe file('C:/sonatype') do
      it { should be_directory }
      it { should be_owned_by 'nexus' }
    end

    describe file('C:/sonatype/nexus') do
      it { should be_owned_by 'nexus' }
    end

    describe file('C:/repository/data') do
      it { should be_directory }
      it { should be_owned_by 'nexus' }
    end

    describe service('nexus') do
      it { should be_enabled }
      it { should be_running }
    end

    ping = <<-EOF
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f 'admin','admin123'))); \
Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} \
-URI http://localhost:8081/service/metrics/ping
EOF

    describe command("powershell -command { #{ping.strip} }") do
      its(:stdout) { should contain('pong') }
    end
  else
    describe file('/opt/sonatype') do
      it { should be_directory }
      it { should be_owned_by 'nexus' }
    end

    describe file('/opt/sonatype/nexus') do
      it { should be_symlink }
      it { should be_owned_by 'nexus' }
    end

    describe file('/opt/repository/data') do
      it { should be_directory }
      it { should be_owned_by 'nexus' }
    end

    describe service('nexus') do
      it { should be_enabled } unless os[:family] == 'debian'
      it { should be_running }
    end

    describe command('curl -u admin:admin123 http://localhost:8081/service/metrics/ping') do
      its(:stdout) { should contain('pong') }
    end
  end
end
