include_recipe 'java' unless platform_family?('windows')

package 'curl'

# Installation with default settings
nexus3 'foo'

# Second installation on the same machine with altered settings (not
# tested on Windows).
# This shows it can be done. Integration tests show
# that one must not miss changing any property or files will be
# overwritten.
unless platform_family?('windows')
  nexus3 'bar' do
    path '/usr/local/nexusbar'
    data '/usr/local/nexusdata'
    nexus3_user 'nexusbar'
    nexus3_group 'nexusbar'
    nexus3_home '/home/nexusbar'
    properties_variables(
      port: '8082'
    )
  end
end
