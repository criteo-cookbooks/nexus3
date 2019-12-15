# The nexus3_resources_tests attributes are used to automatically generate test cases to:
#  * test that update is properly performed at first run
#  * test that update is not performed at next runcs (idempotency)
# When adding a new resource to this project, please:
#  * duplicate this file and rename it with the name of your resource
#  * uncomment below lines and replace the placeholders with valid values

## Test <RESOURCE_NAME> resource
##  action: <ACTION1> (create for instance)
#default['nexus3_resources_test']['<RESOURCE_NAME>']['<ACTION1>']['<TEST_ID>']['<NAME_ATTRIBUTE>'] = '<NAME1>'
#default['nexus3_resources_test']['<RESOURCE_NAME>']['<ACTION1>']['<TEST_ID>']['<ATTRIBUTE1>'] = '<VALUE1>'
# Test update
#default['nexus3_resources_test']['<RESOURCE_NAME>']['<ACTION1>']['<TEST_ID2>']['<NAME_ATTRIBUTE>'] = '<NAME1>'
#default['nexus3_resources_test']['<RESOURCE_NAME>']['<ACTION1>']['<TEST_ID2>']['<ATTRIBUTE1>'] = '<VALUE2>'
## Test other attributes combination
#default['nexus3_resources_test']['<RESOURCE_NAME>']['<ACTION1>']['<TEST_ID3>']['<NAME_ATTRIBUTE>'] = '<NAME2>'
#default['nexus3_resources_test']['<RESOURCE_NAME>']['<ACTION1>']['<TEST_ID3>']['<ATTRIBUTE2>'] = '<VALUE3>'
#default['nexus3_resources_test']['<RESOURCE_NAME>']['<ACTION1>']['<TEST_ID3>']['<ATTRIBUTE3>'] = '<VALUE4>'
##  action: <ACTION2> (delete for instance)
#default['nexus3_resources_test']['<RESOURCE_NAME>']['<ACTION2>']['<TEST_ID4>']['<NAME_ATTRIBUTE>'] = '<NAME1>'
