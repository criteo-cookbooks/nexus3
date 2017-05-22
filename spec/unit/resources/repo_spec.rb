require 'spec_helper'

describe 'nexus3_test::create_repo' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: 'nexus3_api',
                               file_cache_path: CACHE).converge(described_recipe)
    end

    it 'creates a repo' do
      expect(chef_run).to create_script('create foo').with(
        repo_name: 'foo',
        repo_type: 'maven-hosted'
      )
    end

    it 'retrieves a repo configuration' do
      expect(chef_run).to create_script('get_repo').with(repo_name: 'foo')
    end

    it 'deletes a repo' do
      expect(chef_run).to create_script('delete_repo').with(repo_name: 'foo')
    end
  end
end
