require 'chefspec'
require 'chefspec/berkshelf'

VER = '3.5.1-02'.freeze
CACHE = Chef::Config[:file_cache_path]

ChefSpec::Coverage.start!
