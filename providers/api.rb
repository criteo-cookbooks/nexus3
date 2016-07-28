use_inline_resources

def whyrun_supported?
  true
end

def cache_dir(cache_dir = "#{Chef::Config[:file_cache_path]}/nexus")
  directory cache_dir do
    recursive true
  end
  cache_dir
end

def list_dir(list_dir = "#{cache_dir}/list")
  directory list_dir do
    recursive true
  end
  list_dir
end

def scripts_dir(scripts_dir = "#{cache_dir}/scripts")
  directory scripts_dir do
    recursive true
  end
  scripts_dir
end

def upload_script
  delete_script

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
  end

  execute "upload script #{new_resource.script_name}" do
    command "curl -v --fail -X POST -u #{new_resource.username}:#{new_resource.password}" \
        " --header \"Content-Type: application/json\" '#{new_resource.endpoint}' -d @#{new_resource.script_name}.json"
    cwd scripts_dir
    live_stream new_resource.live_stream
    sensitive new_resource.sensitive
    action :run
  end
end

def run_script
  upload_script
  args = new_resource.args.nil? ? '' : "-d #{new_resource.args.join(' -d ')}"
  execute "run script #{new_resource.script_name}" do
    command "curl -v -X POST -u #{new_resource.username}:#{new_resource.password}" \
        " --header \"Content-Type: application/json\" \"#{new_resource.endpoint}\" #{args}"
    live_stream new_resource.live_stream
    sensitive new_resource.sensitive
    action :run
  end
end

def delete_script
  execute "delete script #{new_resource.script_name}" do
    command "curl -v -X DELETE -u #{new_resource.username}:#{new_resource.password}" \
      " '#{new_resource.endpoint}/#{new_resource.script_name}'"
    live_stream new_resource.live_stream
    sensitive new_resource.sensitive
    action :run
  end
end

def list_scripts
  list_file = "#{list_dir}/#{new_resource.script_name.tr(' ', '_')}.json"

  file list_file do
    content '{}'
    mode '0755'
    action :create
  end

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
        script.delete('content') if new_resource.sensitive # suppress content
        next unless script['name'] == new_resource.script_name
        pp script
        match = true
        break
      end
      pp obj unless match
    end
    action :run
    only_if { ::File.exist?(list_file) }
  end
end

action :run do
  converge_by('run script') do
    run_script
  end
end

action :upload do
  converge_by('upload script') do
    upload_script
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
