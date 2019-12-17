require_relative 'inspec_helper'

title 'nexus3_tasks'

# Check that scripts exist
%w[get_task upsert_task delete_task].each do |script_name|
  describe nexus3_script_get(script_name) do
    its('status') { should cmp 200 }
    its('body') { should match(/"type"\s+:\s+"groovy"/) }
  end
end

# Check correct response on invalid task
[nil, '', 'missing-task'].each do |invalid_task|
  describe nexus3_script_post('get_task/run', invalid_task) do
    its('status') { should cmp 200 }
    its('body') { should match(/"result"\s+:\s+"null"/) }
  end
end

# Check correct response on existing task
describe nexus3_script_post('get_task/run', 'integration_task') do
  its('status') { should cmp 200 }
  its('body') { should match(/"result"\s+:\s+".*\Wname\W+:\W+integration_task\W.*"/) }
end
