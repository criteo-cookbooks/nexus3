require 'spec_helper'

describe 'nexus3_test::repositories' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: 'nexus3_repo',
                               file_cache_path: CACHE).converge(described_recipe)
    end

    before do
      stub_request(:post, 'http://localhost:8081/service/siesta/rest/v1/script/get_repo/run')
        .with(basic_auth: %w(admin admin123))
        .with(body: 'foo', headers: { 'Content-Type' => 'text/plain' })
        .to_return(api_response(404),
                   script_response('foo'))

      stub_request(:post, 'http://localhost:8081/service/siesta/rest/v1/script/get_repo/run')
        .with(basic_auth: %w(admin admin123))
        .with(body: 'bar', headers: { 'Content-Type' => 'text/plain' })
        .to_return(api_response(404),
                   script_response('bar'),
                   script_response('bar'))
    end

    it 'creates a repo' do
      expect(chef_run).to create_nexus3_repo('bar')
      expect(chef_run).to create_nexus3_api('get_repo')
      expect(chef_run).to create_nexus3_api('upsert_repo')
      expect(chef_run).to run_nexus3_api('upsert_repo').with(
        repo_name: 'bar',
        repo_type: 'maven2-hosted'
      )
    end

    it 'deletes a repo' do
      expect(chef_run).to delete_nexus3_repo('bar')
      expect(chef_run).to create_nexus3_api('get_repo')
      expect(chef_run).to create_nexus3_api('delete_repo')
      expect(chef_run).to run_nexus3_api('delete_repo').with(repo_name: 'bar')
    end
  end
end
