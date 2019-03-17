require 'spec_helper'

describe 'nexus3_test::cleanup_policies' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: CENTOS_VERSION,
                               file_cache_path: CACHE).converge(described_recipe)
    end

    it 'creates a cleanup policy' do
      expect(chef_run).to create_nexus3_cleanup_policy('foo')
    end

    it 'deletes a cleanup policy' do
      expect(chef_run).to create_nexus3_cleanup_policy('bar')
      expect(chef_run).to delete_nexus3_cleanup_policy('bar')
    end
  end
end
