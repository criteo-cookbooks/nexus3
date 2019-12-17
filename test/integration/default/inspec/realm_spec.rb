require_relative 'inspec_helper'

title 'nexus3_realm'

# Check that scripts exist (since we used them in kitchen)
%w[get_realm_status configure_realm].each do |script_name|
  describe nexus3_script_get(script_name) do
    its('status') { should cmp 200 }
    its('body') { should match(/"type"\s+:\s+"groovy"/) }
  end
end

# Check correct response on invalid realm
[nil, '', 'missing-realm'].each do |invalid_realm|
  describe nexus3_script_post('get_realm_status/run', invalid_realm) do
    its('status') { should cmp 200 }
    its('body') { should match(/"result"\s+:\s+"false"/) }
  end
end

# Check correct response on existing realm
describe nexus3_script_post('get_realm_status/run', 'rutauth-realm') do
  its('status') { should cmp 200 }
  its('body') { should match(/"result"\s+:\s+"true"/) }
end
