require 'spec_helper'

describe 'nexus3_test::change_admin_password' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos',
                               version: CENTOS_VERSION,
                               step_into: 'nexus3',
                               file_cache_path: CACHE)
                          .converge('nexus3_test::default', 'nexus3_test::change_admin_password')
    end

    it 'set admin credentials' do
      resource = chef_run.nexus3_api('admin_change_password')
      expect(resource).to subscribe_to('nexus3[foo]').on(:create).immediately
      expect(resource).to subscribe_to('nexus3[foo]').on(:run).immediately
      expect(resource).to subscribe_to('nexus3[foo]').on(:delete).immediately

      expect(resource.script_name).to eq 'admin_change_password'
      expect(resource.content).to eq "security.securitySystem.changePassword('admin', args)"
      expect(resource.args).to eq 'newPassword'

      expect(resource).to do_nothing
    end

    it 'Update Nexus Credentials' do
      expect(chef_run).to run_ruby_block('update nexus api credentials for future resources')
    end
  end

  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows',
                               version: '2012R2',
                               step_into: 'nexus3',
                               file_cache_path: CACHE)
                          .converge('nexus3_test::default', 'nexus3_test::change_admin_password')
    end

    it 'set admin credentials' do
      resource = chef_run.nexus3_api('admin_change_password')
      expect(resource).to subscribe_to('nexus3[foo]').on(:create).immediately
      expect(resource).to subscribe_to('nexus3[foo]').on(:run).immediately
      expect(resource).to subscribe_to('nexus3[foo]').on(:delete).immediately

      expect(resource.script_name).to eq 'admin_change_password'
      expect(resource.content).to eq "security.securitySystem.changePassword('admin', args)"
      expect(resource.args).to eq 'newPassword'

      expect(resource).to do_nothing
    end

    it 'Update Nexus Credentials' do
      expect(chef_run).to run_ruby_block('update nexus api credentials for future resources')
    end
  end
end
