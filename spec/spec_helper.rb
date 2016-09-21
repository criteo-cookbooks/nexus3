require 'chefspec'
require 'chefspec/berkshelf'

VER = '-3.0.2-02'.freeze
CACHE = Chef::Config[:file_cache_path]

ChefSpec::Coverage.start!
