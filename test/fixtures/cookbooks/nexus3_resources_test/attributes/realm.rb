# Test realm resource
#  action: configure
default['nexus3_resources_test']['realm']['configure']['nuget']['realm_name'] = 'NuGetApiKey'
default['nexus3_resources_test']['realm']['configure']['nuget']['enable'] = true
default['nexus3_resources_test']['realm']['configure']['npm']['realm_name'] = 'NpmToken'
default['nexus3_resources_test']['realm']['configure']['npm']['enable'] = true
#  test to update the resources
default['nexus3_resources_test']['realm']['configure']['nuget']['realm_name'] = 'NuGetApiKey'
default['nexus3_resources_test']['realm']['configure']['nuget']['enable'] = false
default['nexus3_resources_test']['realm']['configure']['npm']['realm_name'] = 'NpmToken'
default['nexus3_resources_test']['realm']['configure']['npm']['enable'] = true
