require 'spec_helper'

describe 'nexus3_test::user' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: 'nexus3_user',
                               file_cache_path: CACHE).converge(described_recipe)
    end

    before do
      stub_request(:post, 'http://localhost:8081/service/siesta/rest/v1/script/search_user/run')
        .with(basic_auth: %w(admin admin123))
        .with(body: 'uploader-bot', headers: { 'Content-Type' => 'text/plain' })
        .to_return(api_response(404),
                   user_response('uploader-bot'))

      stub_request(:post, 'http://localhost:8081/service/siesta/rest/v1/script/search_user/run')
        .with(basic_auth: %w(admin admin123))
        .with(body: 'doesnotexist', headers: { 'Content-Type' => 'text/plain' })
        .to_return(api_response(404),
                   user_response('doesnotexist'),
                   user_response('doesnotexist'))
    end

    it 'creates a user' do
      expect(chef_run).to create_nexus3_user('uploader')
      expect(chef_run).to create_nexus3_api('search_user uploader-bot')
      expect(chef_run).to create_nexus3_api('create_user uploader-bot')
      expect(chef_run).to run_nexus3_api('create_user uploader-bot').with(
        args: { username: 'uploader-bot', password: 'test-1', first_name: '', last_name: '', email: '', roles: [] }
      )
    end

    it 'deletes a user' do
      expect(chef_run).to create_nexus3_user('doesnotexist')
      expect(chef_run).to create_nexus3_api('search_user doesnotexist')
      expect(chef_run).to create_nexus3_api('create_user doesnotexist')
      expect(chef_run).to delete_nexus3_user('doesnotexist')
      expect(chef_run).to create_nexus3_api('delete_user doesnotexist')
      expect(chef_run).to run_nexus3_api('delete_user doesnotexist').with(
        args: { username: 'doesnotexist' }
      )
    end
  end
end
