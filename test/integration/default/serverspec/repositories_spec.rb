require 'serverspec_helper'

describe 'nexus::repositories' do
  if os[:family] == 'windows'
    auth_info = "$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes((\"{0}:{1}\" \
-f 'admin','admin123')));"
    textplain = "-ContentType 'text/plain'"
    applicationjson = "-ContentType 'application/json'"
    base_uri = '-URI http://localhost:8081/service/siesta/rest/v1/script'

    create_script_get_repo = "#{auth_info} Invoke-RestMethod -Headers @{Authorization=(\"Basic {0}\" \
-f $base64AuthInfo)} #{base_uri} -Method POST #{applicationjson} -Body '{\"name\":\"get_repo\",\"type\":\"groovy\",\
\"content\":\"repository.repositoryManager.get(args)\"}'"

    run_script_foo = "#{auth_info} Invoke-RestMethod -Headers @{Authorization=(\"Basic {0}\" -f $base64AuthInfo)} \
#{base_uri}/get_repo/run -Method POST #{textplain}"

    run_get_repo_foo = "#{auth_info} Invoke-RestMethod -Headers @{Authorization=(\"Basic {0}\" -f $base64AuthInfo)} \
#{base_uri}/get_repo/run -Method POST #{textplain} -Body 'foo'"

    run_get_repo_doesnotexist = "#{auth_info} Invoke-RestMethod -Headers @{Authorization=(\"Basic {0}\" \
-f $base64AuthInfo)} #{base_uri}/get_repo/run -Method POST #{textplain} -Body 'doesnotexist'"

    describe command("powershell -command { #{create_script_get_repo} }") do
      its(:exit_status) { should eq 1 }
    end

    describe command("powershell -command { #{run_script_foo} }") do
      its(:exit_status) { should eq 1 }
    end

    describe command("powershell -command { #{run_get_repo_foo} }") do
      its(:stdout) { should contain('result') }
      its(:stdout) { should contain('get_repo') }
    end

    describe command("powershell -command { #{run_get_repo_doesnotexist} }") do
      its(:stdout) { should contain('get_repo').before('null') }
    end
  else # Linux
    describe command('curl -uadmin:admin123 http://localhost:8081/service/siesta/rest/v1/script -X POST ' \
                     '-H "Content-Type: application/json" -d \'{"name":"get_repo","type":"groovy",' \
                     '"content":"repository.repositoryManager.get(args)"}\'') do
      its(:exit_status) { should eq 0 }
    end

    describe command('curl -uadmin:admin123 http://localhost:8081/service/siesta/rest/v1/script/foo/run ' \
                     '-X POST -H "Content-Type: text/plain"') do
      its(:exit_status) { should eq 0 }
    end

    describe command('curl -uadmin:admin123 http://localhost:8081/service/siesta/rest/v1/script/get_repo/run ' \
                     '-X POST -H "Content-Type: text/plain" -d foo') do
      its(:stdout) { should contain('result').before('repositoryName=').before('foo') }
    end

    describe command('curl -uadmin:admin123 http://localhost:8081/service/siesta/rest/v1/script/get_repo/run ' \
                     '-X POST -H "Content-Type: text/plain" -d doesnotexist') do
      its(:stdout) { should contain('result').before('null') }
    end
  end
end
