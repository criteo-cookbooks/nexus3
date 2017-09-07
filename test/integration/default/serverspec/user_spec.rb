require 'serverspec_helper'

describe 'nexus::user' do
  describe command('curl -uadmin:admin123 http://localhost:8081/service/siesta/rest/v1/script -X POST ' \
                   '-H "Content-Type: application/json" -d \'{"name":"search_user","type":"groovy",' \
                   '"content":"security.Security.getUser(args)"}\'') do
    its(:exit_status) { should eq 0 }
  end

  describe command('curl -uadmin:admin123 http://localhost:8081/service/siesta/rest/v1/script/search_user/run ' \
                   '-X POST -H "Content-Type: text/plain"') do
    its(:exit_status) { should eq 0 }
  end

  describe command('curl -uadmin:admin123 http://localhost:8081/service/siesta/rest/v1/script/search_user/run ' \
                   '-X POST -H "Content-Type: text/plain" -d uploader-bot') do
    its(:stdout) do
      should contain('{
  "name" : "search_user",
  "result" : "uploader-bot"
}')
    end
  end

  describe command('curl -uadmin:admin123 http://localhost:8081/service/siesta/rest/v1/script/search_user/run ' \
                   '-X POST -H "Content-Type: text/plain" -d doesnotexist') do
    its(:stdout) do
      should contain('{
  "name" : "search_user",
  "result" : "javax.script.ScriptException: org.sonatype.nexus.security.user.UserNotFoundException: User not found: ' \
                     'doesnotexist"
}')
    end
  end
end
