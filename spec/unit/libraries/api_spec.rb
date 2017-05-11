# coding: utf-8
require_relative '../../spec_helper'

describe 'Nexus3::Api' do
  let(:api_client) do
    Nexus3::Api.new('http://localhost/sample/api', 'admin', 'admin123')
  end

  let(:repo_list) do
    [
      {
        'name' => 'foo',
        'content' => 'repository.createMavenHosted(\'foo\')',
        'type' => 'groovy',
      },
      {
        'name' => 'anonymous',
        'content' => 'security.setAnonymousAccess(Boolean.valueOf(args))',
        'type' => 'groovy',
      },
    ]
  end

  before(:each) do
    WebMock.disable_net_connect!
  end

  describe 'list_repositories' do
    it 'returns repos' do
      # TODO: if we add the Authorization header, the test fails, so
      # it may mean that the api http_client does not send the header.
      stub_request(:get, 'http://localhost/sample/api')
        .with(basic_auth: ['admin', 'admin123'])
        .to_return(body: json_response(repo_list), headers: { 'Content-Type' => 'application/json' })

      expect(api_client.list_repositories).to eq(repo_list)
    end

    # TODO: add other tests, especially ones which return !200
  end

  after(:each) do
    WebMock.allow_net_connect!
  end
end
