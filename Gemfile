source 'https://rubygems.org'

gem 'berkshelf'
gem 'chef', '>= 12.10.27'
gem 'chef-zero', '< 14.0' if ::Gem::Version.new(RUBY_VERSION) < ::Gem::Version.new('2.4.3')
gem 'chefspec'
gem 'fakefs'
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
gem 'faraday', '<0.16.0' # Newer version is incompatible with this cookbook.
gem 'kitchen-inspec'
gem 'rspec-retry'
gem 'rubocop', '=0.47.1'
