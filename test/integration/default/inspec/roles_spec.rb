require_relative 'inspec_helper'

title 'nexus3_roles'

# Check that scripts exist
%w[get_role upsert_role delete_role].each do |script_name|
  describe nexus3_script_get(script_name) do
    its('status') { should cmp 200 }
    its('body') { should match(/"type"\s+:\s+"groovy"/) }
  end
end

# Check correct response on invalid role
[nil, '', 'missing-role'].each do |invalid_role|
  describe nexus3_script_post('get_role/run', invalid_role) do
    its('status') { should cmp 200 }
    its('body') { should match(/"result"\s+:\s+"null"/) }
  end
end

# Check correct response on existing role
describe nexus3_script_post('get_role/run', 'integration_role') do
  its('status') { should cmp 200 }
  its('body') { should match(/"result"\s+:\s+".*\Wrole\W+:\W+integration_role\W.*"/) }
end
