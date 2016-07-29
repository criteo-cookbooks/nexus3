# adds or updates 'anonymous' script on repository manager and executes it with an argument
nexus3_api 'anonymous' do
  script_source 'anonymous.json'
  args 'false'
  action :run
end
