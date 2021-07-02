# Create any resource on which you want other resources to depend on
# but cannot guarantee run order.
nexus3_routing_rule 'mavenrule' do
  matchers ['.*/latest$']
end

# Create repo so we can create components
nexus3_repo 'maven-write-component' do
  repo_type 'maven2-hosted'
  attributes node['nexus3_resources_test']['repo']['create']['maven']['attributes']
end

# Create file to be uploaded as component asset
file '/tmp/asset.txt' do
  content "Hello Nexus3\n"
end
