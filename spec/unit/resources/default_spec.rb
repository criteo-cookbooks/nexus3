require 'spec_helper'

describe 'nexus3_test::default' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: 'nexus3',
                               file_cache_path: CACHE).converge(described_recipe)
    end

    it 'installs Nexus3' do
      expect(chef_run).to install_nexus3('foo')
    end

    it 'creates nexus group' do
      expect(chef_run).to create_group('nexus')
    end

    it 'creates nexus user' do
      expect(chef_run).to create_user('nexus')
    end

    it 'creates install dir' do
      expect(chef_run).to create_directory("/opt/nexus-#{VER}")
    end

    it 'creates data dir' do
      expect(chef_run).to create_directory('/opt/sonatype-work/nexus3')
    end

    it 'creates etc dir' do
      expect(chef_run).to create_directory('/opt/sonatype-work/nexus3/etc')
    end

    it 'extracts nexus tarball' do
      expect(chef_run).to put_ark("nexus-#{VER}")
    end

    it 'creates rc template' do
      expect(chef_run).to create_template("/opt/nexus-#{VER}/bin/nexus.rc")
      expect(chef_run.template("/opt/nexus-#{VER}/bin/nexus.rc"))
        .to notify('log[foo is restarting]').delayed
    end

    it 'creates vmoptions template' do
      expect(chef_run).to create_template("/opt/nexus-#{VER}/bin/nexus.vmoptions")
      expect(chef_run.template("/opt/nexus-#{VER}/bin/nexus.vmoptions"))
        .to notify('log[foo is restarting]').delayed
    end

    it 'creates properties template' do
      expect(chef_run).to create_template('/opt/sonatype-work/nexus3/etc/nexus.properties')
      expect(chef_run.template('/opt/sonatype-work/nexus3/etc/nexus.properties'))
        .to notify('log[foo is restarting]').delayed
    end

    it 'creates homedir symlink' do
      expect(chef_run).to create_link('/opt/nexus3')
    end

    it 'enables nexus service' do
      expect(chef_run).to enable_nexus3_service('foo')
    end

    it 'logs a service restart' do
      expect(chef_run.log('foo is restarting')).to do_nothing
    end

    it 'blocks until operational does nothing' do
      expect(chef_run.ruby_block('block until operational')).to do_nothing
    end
  end

  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2', step_into: 'nexus3',
                               file_cache_path: CACHE).converge(described_recipe)
    end

    it 'installs Nexus3' do
      expect(chef_run).to install_nexus3('foo')
    end

    it 'creates nexus group' do
      expect(chef_run).to create_group('Administrators')
    end

    it 'creates nexus user' do
      expect(chef_run).to create_user('nexus')
    end

    it 'creates install dir' do
      expect(chef_run).to create_directory("C:\\Nexus3/nexus-#{VER}")
    end

    it 'creates data dir' do
      expect(chef_run).to create_directory('C:\Nexus3/sonatype-work/nexus3')
    end

    it 'creates etc dir' do
      expect(chef_run).to create_directory('C:\Nexus3/sonatype-work/nexus3/etc')
    end

    it 'extracts nexus tarball' do
      expect(chef_run).to put_ark("nexus-#{VER}")
    end

    it 'creates rc template' do
      expect(chef_run).to create_template("C:\\Nexus3/nexus-#{VER}/bin/nexus.rc")
      expect(chef_run.template("C:\\Nexus3/nexus-#{VER}/bin/nexus.rc"))
        .to notify('log[foo is restarting]').delayed
    end

    it 'creates vmoptions template' do
      expect(chef_run).to create_template("C:\\Nexus3/nexus-#{VER}/bin/nexus.vmoptions")
      expect(chef_run.template("C:\\Nexus3/nexus-#{VER}/bin/nexus.vmoptions"))
        .to notify('log[foo is restarting]').delayed
    end

    it 'creates properties template' do
      expect(chef_run).to create_template('C:\Nexus3/sonatype-work/nexus3/etc/nexus.properties')
      expect(chef_run.template('C:\Nexus3/sonatype-work/nexus3/etc/nexus.properties'))
        .to notify('log[foo is restarting]').delayed
    end

    it 'creates homedir symlink' do
      expect(chef_run).to create_link('C:\Nexus3/nexus3')
    end

    it 'enables nexus service' do
      expect(chef_run).to enable_nexus3_service('foo')
    end

    it 'logs a service restart' do
      expect(chef_run.log('foo is restarting')).to do_nothing
    end

    it 'blocks until operational does nothing' do
      expect(chef_run.ruby_block('block until operational')).to do_nothing
    end
  end
end
