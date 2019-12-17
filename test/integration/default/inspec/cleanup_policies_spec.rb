require_relative 'inspec_helper'

title 'nexus3_cleanup_policies'

# Check that scripts exist
%w[get_cleanup_policy upsert_cleanup_policy delete_cleanup_policy].each do |script_name|
  describe nexus3_script_get(script_name) do
    its('status') { should cmp 200 }
    its('body') { should match(/"type"\s+:\s+"groovy"/) }
  end
end

# Check correct response on invalid cleanup_policy
[nil, '', 'missing-cleanup_policy'].each do |invalid_cleanup_policy|
  describe nexus3_script_post('get_cleanup_policy/run', invalid_cleanup_policy) do
    its('status') { should cmp 200 }
    its('body') { should match(/"result"\s+:\s+"null"/) }
  end
end

# Check correct response on existing cleanup_policy
describe nexus3_script_post('get_cleanup_policy/run', 'integration_cleanup_policy') do
  its('status') { should cmp 200 }
  its('body') { should match(/"result"\s+:\s+".*\Wname\W+:\W+integration_cleanup_policy\W.*"/) }
end
