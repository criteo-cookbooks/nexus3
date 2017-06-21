include_recipe 'java_se'
include_recipe 'nexus3'

# The default Kitchen image may not be up-to-date.
apt_update 'update' do
  action :update
end

# On Debian-style systems, curl is not installed on the kitchen
# images. Install it here since we only need it for testing.
package 'curl' do
  only_if { platform_family?('debian') }
end
