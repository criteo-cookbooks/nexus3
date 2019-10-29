require_relative 'inspec_helper'

title 'nexus::groups'

if os[:family] == 'windows'
  auth_info = "$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes((\"{0}:{1}\" \
-f 'admin','admin123')));"
  base_uri = '-URI http://localhost:8081/service/rest/v1/script'

  run_get_group = "#{auth_info} Invoke-RestMethod -Headers @{Authorization=(\"Basic {0}\" -f $base64AuthInfo)} \
#{base_uri}/get_repo/run -Method POST -ContentType 'text/plain' -Body '%{group}'"

  describe command("powershell -command { #{run_get_group} }" % { group: 'foo-group' }) do
    its(:stdout) { should match(/foo-group.*result/) }
  end

  describe command("powershell -command { #{run_get_group_doesnotexist} }" % { group: nil }) do
    its(:stdout) { should match(/null.*get_repo/) }
  end
else # Linux
  describe command('curl -uadmin:admin123 http://localhost:8081/service/rest/v1/script/get_repo/run ' \
                   '-X POST -H "Content-Type: text/plain" -d foo-group') do
    its(:stdout) { should match(/"result".*repositoryName.*foo-group/) }
  end

  describe command('curl -uadmin:admin123 http://localhost:8081/service/rest/v1/script/get_repo/run ' \
                   '-X POST -H "Content-Type: text/plain" -d doesnotexist') do
    its(:stdout) { should match('result" : "null') }
  end
end
