use_inline_resources

def whyrun_supported?
  true
end

def create_script
  delete_script

  scripts_dir = "#{Chef::Config[:file_cache_path]}/nexus/scripts"

  directory scripts_dir do
    recursive true
  end

  cookbook_file "#{scripts_dir}/#{new_resource.script_name}.json" do
    cookbook new_resource.script_cookbook
    source new_resource.script_source
    mode '0755'
    not_if { new_resource.script_source.nil? }
  end

  file "#{scripts_dir}/#{new_resource.script_name}.json" do
    content <<EOF
{
  "name": "#{new_resource.script_name}",
  "type": "#{new_resource.type}",
  "content": "#{new_resource.content}"
}
EOF
    mode '0755'
    not_if { new_resource.content.nil? }
    only_if { new_resource.script_source.nil? }
  end

  install_curl

  execute "upload script #{new_resource.script_name}" do
    command "curl -v #{fail_silently} -X POST -u #{new_resource.username}:#{new_resource.password}" \
        " --header \"Content-Type: application/json\" '#{new_resource.endpoint}' -d @#{new_resource.script_name}.json"
    cwd scripts_dir
    live_stream new_resource.live_stream
    sensitive new_resource.sensitive
    action :run
  end
end

def fail_silently
  new_resource.fail_silently ? '' : '--fail'
end

def args(args = new_resource.args)
  return '' if args.nil?
  case args
  when Array
    "-d '#{args.join("' -d '")}'"
  when String
    "-d '#{args}'"
  end
end

def install_curl
  package 'curl' if platform_family?('debian')
end

def run_script
  create_script unless new_resource.script_source.nil? && new_resource.content.nil?

  install_curl

  execute "run script #{new_resource.script_name}" do
    command "curl -v #{fail_silently} -X POST -u #{new_resource.username}:#{new_resource.password}" \
        " --header \"Content-Type: text/plain\" '#{new_resource.endpoint}/#{new_resource.script_name}/run' #{args}"
    live_stream new_resource.live_stream
    sensitive new_resource.sensitive
    action :run
  end
end

def delete_script
  install_curl

  execute "delete script #{new_resource.script_name}" do
    command "curl -v -X DELETE -u #{new_resource.username}:#{new_resource.password}" \
      " '#{new_resource.endpoint}/#{new_resource.script_name}'"
    live_stream new_resource.live_stream
    sensitive new_resource.sensitive
    action :run
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
    mode '0755'
    action :create
  end

  install_curl

  execute "write #{list_file}" do
    command "curl -v -X GET -u #{new_resource.username}:#{new_resource.password} '#{new_resource.endpoint}'" \
      " -o \"#{list_file}\""
    live_stream new_resource.live_stream
    sensitive new_resource.sensitive
    action :run
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
  converge_by('run script') do
    run_script
  end
end

action :create do
  converge_by('create script') do
    create_script
  end
end

action :delete do
  converge_by('delete script') do
    delete_script
  end
end

action :list do
  converge_by('list scripts') do
    list_scripts
  end
end
