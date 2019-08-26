return if ::File.exist?("#{node['nexus3']['data']}/admin.password.updated")

file "#{node['nexus3']['data']}/admin.password.updated" do
  action :nothing
  subscribes :create, 'nexus3_api[admin_change_password]', :immediately
end

ruby_block 'read generated admin password' do
  block do
    node.override['nexus3']['api']['password_wanted'] = node['nexus3']['api']['password']
    # Use intermediary attribute just so we can test it.
    node.override['nexus3']['api']['password_generated'] = ::File.read("#{node['nexus3']['data']}/admin.password")
    node.override['nexus3']['api']['password'] = node['nexus3']['api']['password_generated']
  end
  action :run
end

nexus3_api 'admin_change_password' do
  script_name 'admin_change_password'
  content "security.securitySystem.changePassword('admin', args)"
  args lazy { node['nexus3']['api']['password_wanted'] }
  action %i(create run)
  not_if { node['nexus3']['api']['password_wanted'].nil? }
end

ruby_block 'update nexus api credentials for future resources' do
  block do
    node.override['nexus3']['api']['password'] = node['nexus3']['api']['password_wanted']
  end
  not_if { node['nexus3']['api']['password_wanted'].nil? }
  action :run
end

nexus3_api 'admin_change_password' do
  script_name 'admin_change_password'
  action :delete
end
