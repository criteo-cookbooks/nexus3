require 'chefspec'
require 'chefspec/berkshelf'

VER = '3.3.1-01'.freeze
CACHE = Chef::Config[:file_cache_path]

ChefSpec::Coverage.start!
