# change admin password
nexus3_api 'admin_change_password' do
  context 'security.securitySystem.changePassword("admin", args[0])'
  args 'admin456'
  action :run
end

nexus3_api 'admin_change_password' do
  password 'admin456'
  context 'security.securitySystem.changePassword("admin", args[0])'
  action :run
end

nexus3_api 'admin_change_password' do
  context 'security.securitySystem.changePassword("admin", args[0])'
  args 'admin456'
  action :run
end
