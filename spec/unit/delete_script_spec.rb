require 'spec_helper'

describe 'nexus3_test::delete_script' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: 'nexus3_api',
                               file_cache_path: CACHE).converge(described_recipe)
    end

    it 'creates script' do
      expect(chef_run).to create_nexus3_api('create bar').with(
        script_name: 'bar',
        script_cookbook: 'nexus3',
        script_source: nil,
        content: "repository.createMavenHosted('bar')"
      )
    end

    it 'deletes script' do
      expect(chef_run).to delete_nexus3_api('delete bar').with(
        script_name: 'bar',
        script_cookbook: 'nexus3',
        script_source: nil,
        content: nil
      )
    end

    it 'deletes script' do
      expect(chef_run).to run_execute('delete script bar')
    end

    it 'copies cookbook file' do
      expect(chef_run).to_not create_cookbook_file("#{Chef::Config[:file_cache_path]}/nexus/scripts/bar.json")
    end

    it 'creates file' do
      expect(chef_run).to create_file("#{Chef::Config[:file_cache_path]}/nexus/scripts/bar.json")
    end

    it 'uploads script' do
      expect(chef_run).to run_execute('upload script bar')
    end

    it 'list scripts' do
      expect(chef_run).to list_nexus3_api('list bar').with(
        script_name: 'bar',
        script_cookbook: 'nexus3',
        script_source: nil,
        content: nil
      )
    end

    it 'creates list cache dir' do
      expect(chef_run).to create_directory("#{CACHE}/nexus/list")
    end

    it 'creates file' do
      expect(chef_run).to create_file("#{CACHE}/nexus/list/bar.json")
    end

    it 'uploads script' do
      expect(chef_run).to run_execute("write #{CACHE}/nexus/list/bar.json")
    end

    it 'runs script' do
      expect(chef_run).to run_ruby_block('list bar')
    end
  end
end
