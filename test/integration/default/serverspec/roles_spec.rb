require 'serverspec_helper'

describe 'nexus::roles' do
  describe command('curl -uadmin:admin123 http://localhost:8081/service/siesta/rest/v1/script/get_role/run -X POST ' \
                   '-H "Content-Type: text/plain" -d foo') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/result.*role.*foo/) }
  end
end
