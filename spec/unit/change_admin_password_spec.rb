require 'spec_helper'
require 'fakefs/safe'

describe 'nexus3_test::change_admin_password' do
  shared_examples 'update_admin_credentials' do
    it 'reads generated credentials' do
      expect(chef_run).to run_ruby_block('read generated admin password')
      expect(chef_run.node['nexus3']['api']['password_wanted']).to be('newPassword')
      expect(chef_run.node['nexus3']['api']['password_generated']).to be('S3cr3t')
    end

    it 'set admin credentials' do
      resource = chef_run.nexus3_api('admin_change_password')

      expect(resource.script_name).to eq 'admin_change_password'
      expect(resource.content).to eq "security.securitySystem.changePassword('admin', args)"
      expect(resource.args).to eq 'newPassword'

      expect(chef_run).to create_nexus3_api('admin_change_password')
      expect(chef_run).to run_nexus3_api('admin_change_password')
      expect(chef_run).to delete_nexus3_api('admin_change_password')
    end

    it 'Update Nexus Credentials' do
      expect(chef_run).to run_ruby_block('update nexus api credentials for future resources')
    end

    it 'creates guard file' do
      expect(chef_run).to create_file(::File.join(node['nexus3']['data'], 'admin.password.updated'))
    end
  end

  context 'linux' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos',
                                        version: CENTOS_VERSION,
                                        step_into: 'nexus3',
                                        file_cache_path: CACHE) do |node, _|
        node.normal['nexus3']['data'] = '/opt/nexus-data'
        node.normal['nexus3']['api']['password'] = 'newPassword'
      end
      runner.converge('nexus3_test::change_admin_password')
    end

    before do
      ::FakeFS.activate!
      ::FileUtils.mkdir_p('/opt/nexus-data')
      ::File.write('/opt/nexus-data/admin.password', 'S3cr3t')
    end

    after do
      ::FakeFS.deactivate!
    end
  end

  context 'windows' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'windows',
                                        version: '2012R2',
                                        step_into: 'nexus3',
                                        file_cache_path: CACHE) do |node, _|
        node.normal['nexus3']['data'] = 'C:\nexus-data'
        node.normal['nexus3']['api']['password'] = 'newPassword'
      end
      runner.converge('nexus3_test::change_admin_password')
    end

    before do
      ::FakeFS.activate!
      ::FileUtils.mkdir_p('C:\nexus-data')
      ::File.write('C:\nexus-data\admin.password', 'S3cr3t')
    end

    after do
      ::FakeFS.deactivate!
    end
  end
end
