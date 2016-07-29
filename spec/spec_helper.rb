require 'chefspec'
require 'chefspec/berkshelf'

CACHE = Chef::Config[:file_cache_path]
ChefSpec::Coverage.start!
