ruby_block 'wait for nexus to be responsive' do
  block do
    sleep(550)
  end
  action :run
  only_if { node['nexus3']['api']['wait'] }
end
