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

def fetch_list
  list_file = "#{list_dir}/#{new_resource.script_name.gsub(' ', '_')}.json"

  execute "list #{new_resource.script_name}" do
    command "curl -v -X GET -u #{new_resource.username}:#{new_resource.password} '#{new_resource.endpoint}'" \
      " -o \"#{list_file}\""
    live_stream new_resource.live_stream
    sensitive new_resource.sensitive
  end

  file 'ensure file exists' do
    path list_file
    content '{}'
    mode '0755'
    action :create_if_missing
  end

  list_file
end

def upload_script
  delete_script

  file "#{cache_dir}/#{new_resource.script_name}.json" do
    content <<EOF
{
  "name": "#{new_resource.script_name}",
  "type": "#{new_resource.type}",
  "content": "#{new_resource.content}"
}
EOF
    mode '0755'
    not_if { new_resource.content.nil? }
    only_if { new_resource.cookbook_source.nil? }
  end

  execute 'upload script' do
    command "curl -v --fail -X POST -u #{new_resource.username}:#{new_resource.password}" \
        " --header \"Content-Type: application/json\" '#{new_resource.endpoint}' -d @#{new_resource.script_name}.json"
    cwd cache_dir
    live_stream new_resource.live_stream
    sensitive new_resource.sensitive
    action :run
  end
end

def run_script
  upload_script
  args = new_resource.args.nil? ? '' : "-d #{new_resource.args.join(' -d ')}"
  execute "curl -v -X POST -u #{new_resource.username}:#{new_resource.password}" \
        " --header \"Content-Type: application/json\" \"#{new_resource.endpoint}\" #{args}" do
    live_stream new_resource.live_stream
    sensitive new_resource.sensitive
    action :run
  end
end

def delete_script
  execute "delete #{new_resource.script_name}" do
    command "curl -v -X DELETE -u #{new_resource.username}:#{new_resource.password}" \
      " '#{new_resource.endpoint}/#{new_resource.script_name}'"
    live_stream new_resource.live_stream
    sensitive new_resource.sensitive
    action :run
  end
end

def list_scripts
  ruby_block 'display list' do
    block do
      puts '' # line break
      require 'json'
      match = false
      sleep(15) # wait for api transaction to go through
      file = ::File.read(fetch_list)
      obj = ::JSON.parse(file)
      obj.each do |script|
        if script['name'] == new_resource.script_name
          if new_resource.sensitive
            script.delete('content') # suppress content
            pp script
          else
            pp script
          end
          match = true
          break
        end
      end

      unless match
        if new_resource.sensitive
          names = []
          obj.each do |script|
            script.delete('content') # suppress content
            names << script
          end
          pp names
        else
          pp obj
        end
      end
    end
    action :run
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
