require 'spec_helper'

describe 'nexus3::default' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: 'nexus3').converge(described_recipe)
    end

    it 'installs nexus3' do
      expect(chef_run).to install_nexus3('nexus')
    end

    it 'creates root directory' do
      expect(chef_run).to create_directory('/opt/nexus')
    end

    it 'creates data directory' do
      expect(chef_run).to create_directory('/opt/repository/data')
    end

    it 'creates group' do
      expect(chef_run).to create_group('nexus')
    end

    it 'creates user' do
      expect(chef_run).to create_user('nexus')
    end

    it 'downloads server' do
      expect(chef_run).to create_remote_file('http://download.sonatype.com/nexus/3/nexus-3.0.1-01-unix.tar.gz')
    end

    it 'extracts server' do
      expect(chef_run).to_not run_execute('untar nexus')
    end

    it 'updates nexus.rc' do
      expect(chef_run).to create_template('/opt/nexus/nexus-3.0.1-01/bin/nexus.rc')
    end

    it 'updates org.sonatype.nexus.cfg' do
      expect(chef_run).to create_template('/opt/nexus/nexus-3.0.1-01/etc/org.sonatype.nexus.cfg')
    end

    it 'updates nexus.vmoptions' do
      expect(chef_run).to create_file('/opt/nexus/nexus-3.0.1-01/bin/nexus.vmoptions')
    end

    it 'creates home link' do
      expect(chef_run).to create_link('/opt/nexus/nexus3')
    end

    it 'does not create init.d link' do
      expect(chef_run).to create_link('/etc/init.d/nexus')
    end

    it 'creates service' do
      expect(chef_run).to enable_service('nexus')
    end
  end
end
