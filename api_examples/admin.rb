# Change admin password.  Note that the action is set to nothing.  This should
# only be ran once during initial install of Nexus, otherwise, you will get a
# 'wait up to 600 seconds for Nexus Rest API endpoint to respond' exception
# because the default password 'admin123' will be incorrect.
nexus3_api 'admin_change_password' do
  content "security.securitySystem.changePassword('admin', args)"
  args 'admin456'
  action :nothing
end

# Update admin's email address using the new admin password
nexus3_api 'admin_update_email' do
  content "def user = security.securitySystem.getUser('admin');" \
    "user.setEmailAddress('admin@mycompany.com');" \
    "security.securitySystem.updateUser(user);"
  password 'admin456'
  action :run
end
