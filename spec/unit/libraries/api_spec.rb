require_relative '../../spec_helper'
require_relative '../../../libraries/api'

describe 'Nexus3::Api' do
  let(:api_client) do
    Nexus3::Api.new('http://localhost/sample/api/', 'admin', 'admin123')
  end

  it 'does not generate json for a custom content-type' do
    stub_request(:post, 'http://localhost/sample/api/script/rspec/run')
      .with(body: 'example', headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: '{"result":"ok"}')
    expect(api_client.run_script('rspec', 'example')).to eq('ok')
  end

  it 'generates json data for application/json content type' do
    stub_request(:post, 'http://localhost/sample/api/routing-rules')
      .with(body: '{"some":"json"}', headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: '{"result":"ok"}')
    stub_request(:post, 'http://localhost/sample/api/routing-rules')
      .with(body: '["an","array"]', headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: '{"result":"ok"}')

    expect(api_client.add_routing_rule('some' => 'json')).to eq('{"result":"ok"}')
    expect(api_client.add_routing_rule(%w[an array])).to eq('{"result":"ok"}')
  end

  before(:each) do
    WebMock.disable_net_connect!
  end

  after(:each) do
    WebMock.allow_net_connect!
  end
end
