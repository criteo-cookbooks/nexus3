require 'spec_helper'

describe 'nexus3_test::user' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: CENTOS_VERSION, step_into: 'nexus3_user',
                               file_cache_path: CACHE).converge(described_recipe)
    end

    before do
      stub_request(:post, 'http://localhost:8081/service/rest/v1/script/get_user/run')
        .with(basic_auth: %w(admin admin123))
        .with(body: 'uploader-bot', headers: { 'Content-Type' => 'text/plain' })
        .to_return(api_response(404),
                   user_response('uploader-bot'),
                   user_response('uploader-bot'))

      stub_request(:post, 'http://localhost:8081/service/rest/v1/script/get_user/run')
        .with(basic_auth: %w(admin admin123))
        .with(body: 'uploader2-bot', headers: { 'Content-Type' => 'text/plain' })
        .to_return(api_response(404),
                   user_response('uploader2-bot'),
                   user_response('uploader2-bot'))

      stub_request(:post, 'http://localhost:8081/service/rest/v1/script/get_user/run')
        .with(basic_auth: %w(admin admin123))
        .with(body: 'test-with-pass', headers: { 'Content-Type' => 'text/plain' })
        .to_return(api_response(404),
                   user_response('test-with-pass'),
                   user_response('test-with-pass'))

      stub_request(:post, 'http://localhost:8081/service/rest/v1/script/get_user/run')
        .with(basic_auth: %w(admin admin123))
        .with(body: 'doesnotexist', headers: { 'Content-Type' => 'text/plain' })
        .to_return(api_response(404),
                   user_response('doesnotexist'),
                   user_response('doesnotexist'))

      stub_request(:post, 'http://localhost:8081/service/rest/v1/script/get_user/run')
        .with(basic_auth: %w(admin admin123))
        .with(body: 'user_with_role', headers: { 'Content-Type' => 'text/plain' })
        .to_return(api_response(404),
                   user_response('user_with_role'),
                   user_response('user_with_role'))

      stub_request(:get, 'http://localhost:8081/service/metrics/ping')
        .to_return(api_response(200))
    end

    it 'creates a user' do
      expect(chef_run).to create_nexus3_user('uploader')
      expect(chef_run).to create_nexus3_api('get_user uploader-bot')
      expect(chef_run).to create_nexus3_api('upsert_user uploader-bot')
      expect(chef_run).to run_nexus3_api('upsert_user uploader-bot').with(
        args: { username: 'uploader-bot', password: 'test-1', first_name: '', last_name: '', email: '', roles: [] }
      )
    end

    it 'updates a user' do
      expect(chef_run).to create_nexus3_user('uploader2 update')
      expect(chef_run).to create_nexus3_api('get_user uploader2-bot')
      expect(chef_run).to create_nexus3_api('upsert_user uploader2-bot')
      expect(chef_run).to run_nexus3_api('upsert_user uploader2-bot').with(
        args: { username: 'uploader2-bot', password: 'test-2', first_name: 'uploader2', last_name: 'bot',
                email: 'uploader2@example.com', roles: [] }
      )
    end

    it 'changes a password' do
      expect(chef_run).to create_nexus3_user('test-with-pass')
      expect(chef_run).to create_nexus3_api('get_user test-with-pass')
      expect(chef_run).to create_nexus3_api('upsert_user test-with-pass')
      expect(chef_run).to run_nexus3_api('upsert_user test-with-pass').with(
        args: { username: 'test-with-pass', password: 'newpassword', first_name: '', last_name: '',
                email: '', roles: [] }
      )
    end

    it 'deletes a user' do
      expect(chef_run).to create_nexus3_user('doesnotexist')
      expect(chef_run).to create_nexus3_api('get_user doesnotexist')
      expect(chef_run).to create_nexus3_api('upsert_user doesnotexist')
      expect(chef_run).to delete_nexus3_user('doesnotexist')
      expect(chef_run).to create_nexus3_api('delete_user doesnotexist')
      expect(chef_run).to run_nexus3_api('delete_user doesnotexist').with(
        args: 'doesnotexist'
      )
    end
  end
end
