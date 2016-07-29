require 'spec_helper'

describe 'nexus3_test::list_scripts' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: 'nexus3_api',
                               file_cache_path: CACHE).converge(described_recipe)
    end

    it 'list scripts' do
      expect(chef_run).to list_nexus3_api('all').with(
        script_name: 'all',
        script_cookbook: 'nexus3',
        script_source: nil,
        content: nil
      )
    end

    it 'creates list cache dir' do
      expect(chef_run).to create_directory("#{CACHE}/nexus/list")
    end

    it 'creates file' do
      expect(chef_run).to create_file("#{CACHE}/nexus/list/all.json")
    end

    it 'uploads script' do
      expect(chef_run).to run_execute("write #{CACHE}/nexus/list/all.json")
    end

    it 'runs script' do
      expect(chef_run).to run_ruby_block('list all')
    end
  end
end
