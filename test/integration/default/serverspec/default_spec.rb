require 'serverspec_helper'

set :path, '/sbin:/usr/sbin:/usr/local/sbin:$PATH' # for ss used by be_listening

describe 'nexus::default' do
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
      its(:stdout) { should contain('pong') }
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

    %w(foo bar).each do |service|
      describe service("nexus3_#{service}") do
        it { should be_enabled } unless os[:family] == 'debian'
        it { should be_running }
      end
    end

    describe port(8082) do # remove when we have the admin password and can curl
      it { should be_listening }
    end

    describe command('curl -u admin:admin123 http://localhost:8081/service/metrics/ping') do
      its(:stdout) { should contain('pong') }
    end

    describe command('curl -u admin:admin123 http://localhost:8081/service/rest/v1/script/foo') do
      its(:stdout) { should match(/name.*foo/) }
      its(:stdout) { should match(/content.*repository.createMavenHosted.*foo/) }
      its(:stdout) { should match(/type.*groovy/) }
    end

    # describe command(
    #   'curl -u admin:`cat /usr/local/nexusdata/admin.password` http://localhost:8082/service/metrics/ping'
    # ) do
    #   its(:stdout) { should contain('pong') }
    # end
    #
    # [
    #   { port: 8081, password: 'admin123', repo: 'foo' },
    #   { port: 8082, password: '`cat /usr/local/nexusdata/admin.password`', repo: 'wobble' }
    # ].each do |cfg|
    #   describe command("curl -u admin:#{cfg[:password]} http://localhost:#{cfg[:port]}/service/rest/v1/script/foo") do
    #     its(:stdout) { should match(/name.*#{cfg[:repo]}/) }
    #     its(:stdout) { should match(/content.*repository.createMavenHosted.*#{cfg[:repo]}/) }
    #     its(:stdout) { should match(/type.*groovy/) }
    #   end
    # end
  end
end
