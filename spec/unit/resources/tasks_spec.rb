require 'spec_helper'

describe 'nexus3_test::tasks' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: CENTOS_VERSION,
                               file_cache_path: CACHE).converge(described_recipe)
    end

    it 'creates a task' do
      expect(chef_run).to create_nexus3_task('foo')
    end

    it 'deletes a task' do
      expect(chef_run).to create_nexus3_task('bar')
      expect(chef_run).to delete_nexus3_task('bar')
    end
  end
end
