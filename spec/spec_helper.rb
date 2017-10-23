require 'chefspec'
require 'chefspec/berkshelf'
require 'webmock/rspec'

VER = '3.3.1-01'.freeze
CACHE = Chef::Config[:file_cache_path]
CENTOS_VERSION = '7.2.1511'.freeze

def api_response(code, result = {})
  { status: code, headers: { 'Content-Type' => 'application/json' }, body: JSON.generate(result) }
end

def repo_response(reponame)
  api_response(200, result: JSON.generate(repositoryName: reponame,
                                          recipeName: 'maven2-hosted', online: true, attributes: {}))
end

def user_response(username)
  api_response(200, result: JSON.generate(username: username,
                                          password: 'test-1',
                                          first_name: '',
                                          last_name: '',
                                          email: '',
                                          roles: []))
end

RSpec.configure do |config|
  # Disable all http requests
  WebMock.disable_net_connect!(allow: /supermarket.chef.io|files.opscode.com/i)
  config.before(:each) do
    # Reset http stubs
    WebMock.reset!
  end
end

ChefSpec::Coverage.start!
