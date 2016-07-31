# disable anonymous access
nexus3_api 'anonymous' do
  script_source 'anonymous.json'
  args 'false'
  action :run
end
