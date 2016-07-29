# adds or updates 'anonymous' script on repository manager and executes it with an argument
nexus3_api 'anonymous' do
  content 'security.setAnonymousAccess(Boolean.valueOf(args)'
  args 'false'
  action :run
end
