require 'serverspec_helper'

describe 'nexus::repositories' do
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
