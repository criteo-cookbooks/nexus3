source 'https://rubygems.org'

gem 'berkshelf'
gem 'chef', '>= 12.10.27'
gem 'chef-zero', '< 14.0' if ::Gem::Version.new(RUBY_VERSION) < ::Gem::Version.new('2.4.3')
gem 'chefspec'
gem 'foodcritic'
gem 'webmock'

group :integration do
  gem 'kitchen-dokken'
  gem 'kitchen-localhost'
  gem 'kitchen-vagrant'
  gem 'test-kitchen'
  gem 'winrm-fs'
end

# Other gems should go after this comment
gem 'rubocop', '=0.47.1'
