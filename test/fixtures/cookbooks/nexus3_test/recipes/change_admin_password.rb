nexus3_api 'admin_change_password' do
  script_name 'admin_change_password'
  content "security.securitySystem.changePassword('admin', args)"
  args 'newPassword'

  action :nothing

  # nexus3[foo] is created in default recipe
  subscribes :create, 'nexus3[foo]', :immediately
  subscribes :run, 'nexus3[foo]', :immediately
  subscribes :delete, 'nexus3[foo]', :immediately
end

ruby_block 'update nexus api credentials for future resources' do
  block do
    node.override['nexus3']['api']['password'] = 'newPassword'
  end
  action :run
end
