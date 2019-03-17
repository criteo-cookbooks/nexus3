require 'serverspec_helper'

describe 'nexus3_test::cleanup_policies' do
  describe command('curl -uadmin:admin123 http://localhost:8081/service/rest/v1/script/get_cleanup_policy/run ' \
                   '-X POST -H "Content-Type: text/plain" -d foo') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/result.*name.*foo/) }
  end
end
