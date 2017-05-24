require 'chefspec'
require 'chefspec/berkshelf'
require 'webmock/rspec'

VER = '3.3.1-01'.freeze
CACHE = Chef::Config[:file_cache_path]

def api_response(code, result = {})
  { status: code, headers: { 'Content-Type' => 'application/json' }, body: JSON.generate(result) }
end

def script_response(result)
  api_response(200, result: JSON.generate(result))
end

RSpec.configure do |config|
  # Disable all http requests
  WebMock.disable_net_connect!(allow_localhost: true, allow: /supermarket.chef.io|files.opscode.com/i)
  config.before(:each) do
    # Reset http stubs
    WebMock.reset!
  end
end

ChefSpec::Coverage.start!
