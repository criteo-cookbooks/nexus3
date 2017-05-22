require 'chefspec'
require 'chefspec/berkshelf'
require 'webmock/rspec'

WebMock.allow_net_connect!

VER = '3.3.1-01'.freeze
CACHE = Chef::Config[:file_cache_path]

def json_response(result)
  JSON.generate(result)
end

ChefSpec::Coverage.start!
