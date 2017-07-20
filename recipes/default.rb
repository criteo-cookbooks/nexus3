# Usage:
# In your recipe:
# include_recipe 'nexus3'  # to make sure the ark recipe is included
#
# Then to install a specific instance 'foo':
#   nexus3 'foo' do
#     nexus3_user 'nexus'
#     nexus3_group 'nexus'
#     # Add other properties as you see fit
#   end

# This is included here instead of in the resource to avoid execution
# ordering issues explained by
# https://github.com/chef/chef/issues/4260.
include_recipe 'ark'
