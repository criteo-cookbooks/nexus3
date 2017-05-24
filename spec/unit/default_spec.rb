require 'spec_helper'

describe 'nexus3::default' do
  # TODO: stub requests and remove this.
  before do
    WebMock.allow_net_connect!
  end

  after do
    WebMock.disable_net_connect!
  end

  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: 'nexus3').converge(described_recipe)
    end

    it 'installs nexus3' do
      expect(chef_run).to install_nexus3('nexus')
    end

    it 'creates path directory' do
      expect(chef_run).to create_directory('/opt')
    end

    it 'creates data directory' do
      expect(chef_run).to create_directory('/opt/sonatype-work/nexus3')
    end

    it 'creates group' do
      expect(chef_run).to create_group('nexus')
    end

    it 'creates user' do
      expect(chef_run).to create_user('nexus')
    end

    it 'downloads server' do
      expect(chef_run).to create_remote_file("http://download.sonatype.com/nexus/3/nexus-#{VER}-unix.tar.gz")
    end

    it 'extracts server' do
      expect(chef_run).to_not run_execute("untar nexus-#{VER}-unix.tar.gz")
    end

    it 'updates nexus.rc' do
      expect(chef_run).to create_template("/opt/nexus-#{VER}/bin/nexus.rc")
    end

    it 'creates etc dir' do
      expect(chef_run).to create_directory('/opt/sonatype-work/nexus3/etc')
    end

    it 'updates nexus.properties' do
      expect(chef_run).to create_template('/opt/sonatype-work/nexus3/etc/nexus.properties')
    end

    it 'updates nexus.vmoptions' do
      expect(chef_run).to create_template("/opt/nexus-#{VER}/bin/nexus.vmoptions")
    end

    it 'creates home link' do
      expect(chef_run).to create_link('/opt/nexus3')
    end

    it 'creates service' do
      expect(chef_run).to enable_service('nexus')
    end
  end

  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2', step_into: 'nexus3') do
        ENV['SYSTEMDRIVE'] = 'C:'
      end.converge(described_recipe)
    end

    it 'installs nexus3' do
      expect(chef_run).to install_nexus3('nexus')
    end

    it 'creates path directory' do
      expect(chef_run).to create_directory('C:')
    end

    it 'creates data directory' do
      expect(chef_run).to create_directory('C:/sonatype-work/nexus3')
    end

    it 'does not create group' do
      expect(chef_run).to create_group('Administrators')
    end

    it 'creates user' do
      expect(chef_run).to create_user('nexus')
    end

    it 'downloads server' do
      expect(chef_run).to create_remote_file("http://download.sonatype.com/nexus/3/nexus-#{VER}-win64.zip")
    end

    it 'extracts server' do
      expect(chef_run).to_not run_powershell_script("unzip nexus-#{VER}-win64.zip")
    end

    it 'installs server' do
      expect(chef_run).to_not run_batch('install nexus service')
    end

    it 'updates nexus.rc' do
      expect(chef_run).to create_template("C:/nexus-#{VER}/bin/nexus.rc")
    end

    it 'creates etc dir' do
      expect(chef_run).to create_directory('C:/sonatype-work/nexus3/etc')
    end

    it 'updates nexus.properties' do
      expect(chef_run).to create_template('C:/sonatype-work/nexus3/etc/nexus.properties')
    end

    it 'updates nexus.vmoptions' do
      expect(chef_run).to create_template("C:/nexus-#{VER}/bin/nexus.vmoptions")
    end

    it 'creates home link' do
      expect(chef_run).to create_link('C:/nexus3')
    end

    it 'does not create init.d link' do
      expect(chef_run).to_not create_link('/etc/init.d/nexus')
    end

    it 'creates service' do
      expect(chef_run).to enable_service('nexus')
    end
  end
end
