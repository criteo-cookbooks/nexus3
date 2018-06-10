require 'serverspec_helper'

describe 'nexus::user' do
  describe command('curl -uadmin:newPassword http://localhost:8081/service/rest/v1/script -X POST ' \
                   '-H "Content-Type: application/json" -d \'{"name":"get_user","type":"groovy",' \
                   '"content":"security.Security.getUser(args)"}\'') do
    its(:exit_status) { should eq 0 }
  end

  describe command('curl -uadmin:newPassword http://localhost:8081/service/rest/v1/script/get_user/run ' \
                   '-X POST -H "Content-Type: text/plain"') do
    its(:exit_status) { should eq 0 }
  end

  describe command('curl -uadmin:newPassword http://localhost:8081/service/rest/v1/script/get_user/run ' \
                   '-X POST -H "Content-Type: text/plain" -d uploader-bot') do
    its(:stdout) do
      should eq('{
  "name" : "get_user",
  "result" : "{\"username\":\"uploader-bot\",\"first_name\":\"\",\"last_name\":\"\",\"email\":\"\",\"roles\":[]}"
}')
    end
  end

  # rubocop:disable LineLength
  describe command('curl -uadmin:newPassword http://localhost:8081/service/rest/v1/script/get_user/run ' \
                   '-X POST -H "Content-Type: text/plain" -d uploader2-bot') do
    its(:stdout) do
      should eq('{
  "name" : "get_user",
  "result" : "{\"username\":\"uploader2-bot\",\"first_name\":\"uploader2\",\"last_name\":\"bot\",\"email\":\"uploader2@example.com\",\"roles\":[]}"
}')
    end
  end
  # rubocop:enable LineLength

  describe command('curl -uadmin:newPassword http://localhost:8081/service/rest/v1/script/get_user/run ' \
                   '-X POST -H "Content-Type: text/plain" -d doesnotexist') do
    its(:stdout) do
      should eq('{
  "name" : "get_user",
  "result" : "null"
}')
    end
  end
end
