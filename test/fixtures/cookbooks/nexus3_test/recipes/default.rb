openjdk_pkg_install '8' unless platform_family?('windows')

group 'nexusall'

package 'curl'

# Installation with default settings
nexus3 'foo'

# Second installation on the same machine with altered settings (not
# tested on Windows).
unless platform_family?('windows')
  package 'iproute' if platform?('fedora') # inspec tests on fedora-29 need this for `ss`
  nexus3 'bar' do
    path '/usr/local/nexusbar/path'
    data '/usr/local/nexusbar/data'
    nexus3_user 'nexusbar'
    nexus3_group 'nexusbar'
    nexus3_uid 1234
    nexus3_gid 5678
    nexus3_additional_groups ['nexusall']
    nexus3_home '/home/nexusbar'
    nexus3_password 'humdiddle'
    properties_variables(node['nexus3']['properties_variables'].merge('application-port': '8082'))
  end
end
