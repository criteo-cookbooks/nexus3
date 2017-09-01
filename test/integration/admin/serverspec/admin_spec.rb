require 'serverspec_helper'

describe 'nexus::admin' do
  describe command('curl -uadmin:admin456 http://localhost:8081/service/metrics/ping') do
    its(:stdout) { should contain('pong') }
  end
end
