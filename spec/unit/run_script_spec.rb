require 'spec_helper'

describe 'nexus3_test::run_script' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: 'nexus3_api',
                               file_cache_path: CACHE).converge(described_recipe)
    end

    it 'runs script' do
      expect(chef_run).to run_nexus3_api('anonymous').with(
        script_name: 'anonymous',
        script_cookbook: 'nexus3',
        script_source: 'anonymous.json',
        content: nil
      )
    end

    it 'waits for api endpoint to respond' do
      expect(chef_run).to run_ruby_block('wait up to 600 seconds for Nexus Rest API endpoint to respond')
    end

    it 'deletes script' do
      expect(chef_run).to run_execute('delete script anonymous')
    end

    it 'creates scripts cache dir' do
      expect(chef_run).to create_directory("#{CACHE}/nexus/scripts")
    end

    it 'copies cookbook file' do
      expect(chef_run).to create_cookbook_file("#{CACHE}/nexus/scripts/anonymous.json")
    end

    it 'creates file' do
      expect(chef_run).to_not create_file("#{CACHE}/nexus/scripts/anonymous.json")
    end

    it 'uploads script' do
      expect(chef_run).to run_execute('upload script anonymous')
    end

    it 'runs script' do
      expect(chef_run).to run_execute('run script anonymous')
    end
  end

  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'windows', version: '2012R2', step_into: 'nexus3_api', file_cache_path: CACHE
      ) do
        ENV['SYSTEMDRIVE'] = 'C:'
      end.converge(described_recipe)
    end

    it 'runs script' do
      expect(chef_run).to run_nexus3_api('anonymous').with(
        script_name: 'anonymous',
        script_cookbook: 'nexus3',
        script_source: 'anonymous.json',
        content: nil
      )
    end

    it 'waits for api endpoint to respond' do
      expect(chef_run).to run_ruby_block('wait up to 600 seconds for Nexus Rest API endpoint to respond')
    end

    it 'deletes script' do
      expect(chef_run).to run_powershell_script('delete script anonymous')
    end

    it 'creates scripts cache dir' do
      expect(chef_run).to create_directory("#{CACHE}/nexus/scripts")
    end

    it 'copies cookbook file' do
      expect(chef_run).to create_cookbook_file("#{CACHE}/nexus/scripts/anonymous.json")
    end

    it 'creates file' do
      expect(chef_run).to_not create_file("#{CACHE}/nexus/scripts/anonymous.json")
    end

    it 'uploads script' do
      expect(chef_run).to run_powershell_script('upload script anonymous')
    end

    it 'runs script' do
      expect(chef_run).to run_powershell_script('run script anonymous')
    end
  end
end
