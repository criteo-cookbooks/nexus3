# disable anonymous access using json script included in nexus3 cookbook
nexus3_api 'anonymous' do
  script_source 'anonymous.json'
  args 'false'
  action :run
end
