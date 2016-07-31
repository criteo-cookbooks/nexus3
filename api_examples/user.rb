# add user
nexus3_api 'userJaneDoe' do
  content "security.addUser('jane.doe', 'Jane', 'Doe', 'jane.doe@example.com', true, 'changMe123', ['nx-admin'])"
  action :run
end
