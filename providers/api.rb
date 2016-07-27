use_inline_resources

def whyrun_supported?
  true
end

def upload_script
  cache_dir = "#{Chef::Config[:file_cache_path]}/nexus/scripts"

  directory cache_dir do
    recursive true
  end

  file "#{cache_dir}/#{new_resource.name}.json" do
    content <<EOF
{
  "name": "#{new_resource.name}",
  "type": "#{new_resource.type}",
  "content": "#{new_resource.content}"
}
EOF
    mode '0755'
    not_if { new_resource.content.nil? }
  end

  execute 'upload script' do
    command "curl -v -X POST -u #{new_resource.username}:#{new_resource.password}" \
        " --header \"Content-Type: application/json\" \"#{new_resource.endpoint}\" "
    sensitive new_resource.sensitive
    action :run
  end
end

def run_script
  upload_script
  args = new_resource.args.nil? ? '' : "-d #{new_resource.args.join(' -d ')}"
  execute "curl -v -X POST -u #{new_resource.username}:#{new_resource.password}" \
        " --header \"Content-Type: application/json\" \"#{new_resource.endpoint}\" #{args}" do
    sensitive new_resource.sensitive
    action :run
  end
end

def list_script
  args = new_resource.args.nil? ? '' : "-d #{new_resource.args.join(' -d ')}"
  execute "curl -v -X POST -u #{new_resource.username}:#{new_resource.password}" \
        " --header \"Content-Type: application/json\" \"#{new_resource.endpoint}\" #{args}" do
    sensitive new_resource.sensitive
    action :run
  end
end

def delete_script
  args = new_resource.args.nil? ? '' : "-d #{new_resource.args.join(' -d ')}"
  execute "curl -v -X POST -u #{new_resource.username}:#{new_resource.password}" \
        " --header \"Content-Type: application/json\" \"#{new_resource.endpoint}\" #{args}" do
    sensitive new_resource.sensitive
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

action :list do
  converge_by('list script') do
    list_script
  end
end

action :delete do
  converge_by('upload script') do
    delete_script
  end
end
