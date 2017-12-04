require 'serverspec_helper'

describe 'nexus::roles' do
  describe command('curl -uadmin:admin123 http://localhost:8081/service/siesta/rest/v1/script/get_role/run -X POST ' \
                   '-H "Content-Type: text/plain" -d foo') do
    its(:exit_status) { should eq 0 }
    its(:stdout) do
      should eq('{
  "name" : "get_role",
  "result" : "{\"role\":\"foo\",\"description\":\"\",\"roles\":[],\"privileges\":[]}"
}')
    end
  end

  describe command('curl -uadmin:admin123 http://localhost:8081/service/siesta/rest/v1/script/get_role/run -X POST ' \
                   '-H "Content-Type: text/plain" -d doesnotexist') do
    its(:exit_status) { should eq 0 }
    its(:stdout) do
      should eq('{
  "name" : "get_role",
  "result" : "null"
}')
    end
  end

  # rubocop:disable LineLength
  describe command('curl -uadmin:admin123 http://localhost:8081/service/siesta/rest/v1/script/get_role/run -X POST ' \
                   '-H "Content-Type: text/plain" -d baz') do
    its(:exit_status) { should eq 0 }
    its(:stdout) do
      should eq('{
  "name" : "get_role",
  "result" : "{\"role\":\"baz\",\"description\":\"\",\"roles\":[],\"privileges\":[\"nx-blobstores-read\",\"nx-ldap-read\"]}"
}')
    end
  end
  # rubocop:enable LineLength
end
