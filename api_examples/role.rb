# add role
nexus3_api 'role-developer' do
  content "security.addRole('developer', 'Developer'," \
    " 'User with privileges to allow read access to repo content and healthcheck'," \
    " ['nx-healthcheck-read', 'nx-healthcheck-summary-read'], ['nx-anonymous'])"
  action :run
end
