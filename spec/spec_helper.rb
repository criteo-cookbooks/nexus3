require 'chefspec'
require 'chefspec/berkshelf'
require 'webmock/rspec'

VER = '3.8.0-02'.freeze
CACHE = Chef::Config[:file_cache_path]
CENTOS_VERSION = '7.4.1708'.freeze

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

def role_response(rolename)
  api_response(200, result: JSON.generate(role: rolename,
                                          description: 'desc-spec', roles: ['role-spec1', 'role-spec2'],
                                          privileges: ['priv-spec-1', 'priv-spec-2']))
end

def task_response(taskname)
  api_response(200, result: JSON.generate(name: taskname),
                    source: 'println("Hello, World!");')
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
