require_relative 'inspec_helper'

title 'nexus3_group'

describe nexus3_script_post('get_repo/run', 'integration_group') do
  its('status') { should cmp 200 }
  its('body') { should match(/"result"\s+:\s+".*\WrepositoryName\W+:\W+integration_group\W.*"/) }
end
