use_inline_resources

def win_api_prefix
  "$username = '#{new_resource.username}'; $password = '#{new_resource.password}';" \
  '$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)));' \
  'Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}'
end

def health_check
  ruby_block "wait up to #{new_resource.wait} seconds for Nexus Rest API endpoint to respond" do # ~FC014
    block do
      retries = new_resource.wait / 2
      if platform?('windows')
        powershell_script "wait for #{new_resource.endpoint} to respond" do
          code "#{win_api_prefix} -Uri #{new_resource.endpoint}"
          live_stream new_resource.live_stream
          sensitive new_resource.sensitive
          retries retries
          action :run
        end
      else
        execute "wait for #{new_resource.endpoint} to respond" do
          command "curl --fail -X GET -u #{new_resource.username}:#{new_resource.password} '#{new_resource.endpoint}'"
          live_stream new_resource.live_stream
          sensitive new_resource.sensitive
          retries retries
          action :run
        end
      end
    end
    action :run
  end
end

def create_json(scripts_dir)
  cookbook_file "#{scripts_dir}/#{new_resource.script_name}.json" do
    cookbook new_resource.script_cookbook
    source new_resource.script_source
    not_if { new_resource.script_source.nil? }
  end

  file "#{scripts_dir}/#{new_resource.script_name}.json" do
    content <<-EOF
    {
      "name": "#{new_resource.script_name}",
      "type": "#{new_resource.type}",
      "content": "#{new_resource.content}"
    }
    EOF
    not_if { new_resource.content.nil? }
    only_if { new_resource.script_source.nil? }
  end
end

def create_script
  delete_script

  scripts_dir = "#{Chef::Config[:file_cache_path]}/nexus/scripts"

  directory scripts_dir do
    recursive true
  end

  create_json(scripts_dir)

  if platform?('windows')
    powershell_script "upload script #{new_resource.script_name}" do
      code "#{win_api_prefix} -Uri #{new_resource.endpoint} -Method Post -ContentType 'application/json'" \
        " -InFile '#{scripts_dir}/#{new_resource.script_name}.json'"
      returns fail_silently
      live_stream new_resource.live_stream
      sensitive new_resource.sensitive
      action :run
    end
  else
    execute "upload script #{new_resource.script_name}" do
      command "curl -v #{fail_silently} -X POST -u #{new_resource.username}:#{new_resource.password}" \
        " --header \"Content-Type: application/json\" '#{new_resource.endpoint}' -d @#{new_resource.script_name}.json"
      cwd scripts_dir
      live_stream new_resource.live_stream
      sensitive new_resource.sensitive
      action :run
    end
  end
end

def fail_silently
  if platform?('windows')
    new_resource.ignore_failure ? [0, 1] : 0
  else
    new_resource.ignore_failure ? '' : '--fail'
  end
end

def args(args = new_resource.args)
  return '' if args.nil?
  case args
  when Array
    platform?('windows') ? "-Body #{args.join('&')}" : "-d '#{args.join("' -d '")}'"
  when String
    platform?('windows') ? "-Body #{args}" : "-d '#{args}'"
  end
end

def install_curl
  package 'curl' if platform_family?('debian')
end

def run_script
  create_script unless new_resource.script_source.nil? && new_resource.content.nil?

  if platform?('windows')
    powershell_script "run script #{new_resource.script_name}" do
      code "#{win_api_prefix} -Uri #{new_resource.endpoint}/#{new_resource.script_name}/run -Method Post" \
        " -ContentType 'text/plain' #{args}"
      returns fail_silently
      live_stream new_resource.live_stream
      sensitive new_resource.sensitive
      action :run
    end
  else
    execute "run script #{new_resource.script_name}" do
      command "curl -v #{fail_silently} -X POST -u #{new_resource.username}:#{new_resource.password}" \
        " --header \"Content-Type: text/plain\" '#{new_resource.endpoint}/#{new_resource.script_name}/run' #{args}"
      live_stream new_resource.live_stream
      sensitive new_resource.sensitive
      action :run
    end
  end
end

def delete_script
  if platform?('windows')
    powershell_script "delete script #{new_resource.script_name}" do
      code "#{win_api_prefix} -Uri #{new_resource.endpoint}/#{new_resource.script_name} -Method Delete"
      returns [0, 1]
      live_stream new_resource.live_stream
      sensitive new_resource.sensitive
      action :run
    end
  else
    execute "delete script #{new_resource.script_name}" do
      command "curl -v -X DELETE -u #{new_resource.username}:#{new_resource.password}" \
        " '#{new_resource.endpoint}/#{new_resource.script_name}'"
      live_stream new_resource.live_stream
      sensitive new_resource.sensitive
      action :run
    end
  end
end

def list_scripts
  list_dir = "#{Chef::Config[:file_cache_path]}/nexus/list"

  directory list_dir do
    recursive true
  end

  list_file = "#{list_dir}/#{new_resource.script_name.tr(' ', '_')}.json"

  file list_file do
    content '{}'
    action :create
  end

  if platform?('windows')
    powershell_script "write #{list_file}" do
      code "#{win_api_prefix} -Uri #{new_resource.endpoint} -OutFile '#{list_file}'"
      returns [0, 1]
      live_stream new_resource.live_stream
      sensitive new_resource.sensitive
      action :run
    end
  else
    execute "write #{list_file}" do
      command "curl -v -X GET -u #{new_resource.username}:#{new_resource.password} '#{new_resource.endpoint}'" \
        " -o '#{list_file}'"
      live_stream new_resource.live_stream
      sensitive new_resource.sensitive
      action :run
    end
  end

  ruby_block "list #{new_resource.script_name}" do
    block do
      require 'json'
      puts '' # line break
      match = false
      obj = ::JSON.parse(::File.read(list_file))
      obj.each do |script|
        next unless script['name'] == new_resource.script_name
        pp script
        match = true
        break
      end
      pp obj unless match
    end
    action :run
  end
end

action :run do
  install_curl
  health_check
  run_script
end

action :create do
  install_curl
  health_check
  create_script
end

action :delete do
  install_curl
  health_check
  delete_script
end

action :list do
  install_curl
  health_check
  list_scripts
end
