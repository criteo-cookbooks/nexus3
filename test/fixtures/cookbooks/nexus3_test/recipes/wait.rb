ruby_block 'wait for nexus to be responsive' do
  block do
    sleep(node['nexus3']['api']['wait'])
  end
  action :run
  only_if { node['nexus3']['api']['wait'] }
end
