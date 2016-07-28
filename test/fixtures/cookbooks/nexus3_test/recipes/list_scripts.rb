# lists all of the scripts their content, since there is not a script called 'all' on the repository manager
nexus3_api 'all' do
  action :list
end

# lists only 'example' script since it exists on the repository manager
nexus3_api 'example' do
  action :list
end
