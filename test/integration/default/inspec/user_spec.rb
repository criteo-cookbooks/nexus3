require_relative 'inspec_helper'

title 'nexus3_user'

# Check that scripts exist
%w[get_user upsert_user delete_user].each do |script_name|
  describe nexus3_script_get(script_name) do
    its('status') { should cmp 200 }
    its('body') { should match(/"type"\s+:\s+"groovy"/) }
  end
end

# Check correct response on invalid user
[nil, '', 'missing-user'].each do |invalid_user|
  describe nexus3_script_post('get_user/run', invalid_user) do
    its('status') { should cmp 200 }
    its('body') { should match(/"result"\s+:\s+"null"/) }
  end
end

# Check correct response on existing user
describe nexus3_script_post('get_user/run', 'integration_user') do
  its('status') { should cmp 200 }
  its('body') { should match(/"result"\s+:\s+".*\Wusername\W+:\W+integration_user\W.*"/) }
end
