require 'serverspec_helper'

describe 'nexus::realm' do
  describe command('curl -uadmin:admin123 http://localhost:8081/service/rest/v1/script/get_realm_status/run -X POST ' \
                   '-H "Content-Type: text/plain" -d foo') do
    its(:exit_status) { should eq 0 }
  end
end
