require_relative 'inspec_helper'

title 'nexus3_repo'

# Check that scripts exist
%w[get_repo upsert_repo delete_repo].each do |script_name|
  describe nexus3_script_get(script_name) do
    its('status') { should cmp 200 }
    its('body') { should match(/"type"\s+:\s+"groovy"/) }
  end
end

# Check correct response on invalid repo
[nil, '', 'missing-repo'].each do |invalid_repo|
  describe nexus3_script_post('get_repo/run', invalid_repo) do
    its('status') { should cmp 200 }
    its('body') { should match(/"result"\s+:\s+"null"/) }
  end
end

# Check correct response on existing repo
describe nexus3_script_post('get_repo/run', 'integration_repo') do
  its('status') { should cmp 200 }
  its('body') { should match(/"result"\s+:\s+".*\WrepositoryName\W+:\W+integration_repo\W.*"/) }
end
