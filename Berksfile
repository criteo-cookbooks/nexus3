source 'https://supermarket.chef.io'

metadata

group :test do
  cookbook 'ark', '= 5.1.1' # Drop constraint when requiring Chef >= 15
  cookbook 'nexus3_test', path: 'test/fixtures/cookbooks/nexus3_test'
  cookbook 'nexus3_resources_test', path: 'test/fixtures/cookbooks/nexus3_resources_test'
  cookbook 'updatable-attributes'
  cookbook 'windows'
end
