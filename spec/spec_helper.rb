require 'chefspec'
require 'chefspec/berkshelf'

VER = '3.1.0-04'.freeze
CACHE = Chef::Config[:file_cache_path]

ChefSpec::Coverage.start!
