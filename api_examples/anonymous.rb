# enable/disable anonymous access
nexus3_api 'anonymous' do
  content 'security.setAnonymousAccess(Boolean.valueOf(args))'
  args 'false' # disable anonymous access
  action :run
end

# or you can use json cookbook file included in nexus3
# nexus3_api 'anonymous' do
#   script_source 'anonymous.json'
#   args 'true' # enable anonymous access
#   action :run
# end
