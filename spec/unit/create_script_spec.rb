require 'spec_helper'

describe 'nexus3_test::create_script' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: 'nexus3_api',
                               file_cache_path: CACHE).converge(described_recipe)
    end

    it 'creates script' do
      expect(chef_run).to create_nexus3_api('create foo').with(
        script_name: 'foo',
        script_cookbook: 'nexus3',
        script_source: nil,
        content: "repository.createMavenHosted('foo')"
      )
    end

    it 'deletes script' do
      expect(chef_run).to run_execute('delete script foo')
    end

    it 'creates scripts cache dir' do
      expect(chef_run).to create_directory("#{Chef::Config[:file_cache_path]}/nexus/scripts")
    end

    it 'copies cookbook file' do
      expect(chef_run).to_not create_cookbook_file("#{Chef::Config[:file_cache_path]}/nexus/scripts/foo.json")
    end

    it 'creates file' do
      expect(chef_run).to create_file("#{Chef::Config[:file_cache_path]}/nexus/scripts/foo.json")
    end

    it 'uploads script' do
      expect(chef_run).to run_execute('upload script foo')
    end
  end
end
