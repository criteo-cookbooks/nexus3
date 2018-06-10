require 'serverspec_helper'

describe 'nexus::tasks' do
  describe command('curl -uadmin:newPassword http://localhost:8081/service/rest/v1/script/get_task/run -X POST ' \
                   '-H "Content-Type: text/plain" -d foo') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/result.*name.*foo/) }
  end
end
