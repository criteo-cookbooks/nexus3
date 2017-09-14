include_recipe 'java_se'

package 'curl'

# Installation with default settings but updated admin password
nexus3 'foo' do
  nexus3_password node['nexus3']['api']['password']
end

# Second installation on the same machine with altered settings (not
# tested on Windows).
# This shows it can be done. Integration tests show
# that one must not miss changing any property or files will be
# overwritten.
unless platform_family?('windows')
  # node.default['nexus3']['api']['endpoint'] = 'http://localhost:8082'
  nexus3 'bar' do
    path '/usr/local/nexusbar'
    data '/usr/local/nexusdata'
    nexus3_user 'nexusbar'
    nexus3_group 'nexusbar'
    nexus3_home '/home/nexusbar'
    version '3.4.0-02'
    service_name '3.4.0-02'
    properties_variables(
      host: '0.0.0.0',
      port: '8082',
      args: '${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-requestlog.xml',
      context_path: '/'
    )
    api_endpoint 'http://localhost:8082/service/siesta/rest/v1/script/'
  end
end
