# Create any resource on which you want other resources to depend on
# but cannot guarantee run order.
nexus3_routing_rule 'mavenrule' do
  matchers ['.*/latest$']
end
