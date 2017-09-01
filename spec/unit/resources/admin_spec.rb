require 'spec_helper'

describe 'nexus3_test::admin' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: 'nexus3_admin',
                               file_cache_path: CACHE).converge(described_recipe)
    end

    it 'changes admin password' do
      expect(chef_run).to run_nexus3_admin('change_password')
      expect(chef_run).to create_nexus3_api('change_user_password')
      expect(chef_run).to run_nexus3_api('change_user_password').with(
        username: 'admin',
        new_password: 'admin456'
      )
    end
  end
end
