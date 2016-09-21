# create and run rubygems hosted, proxy and group repositories
nexus3_api 'rubygems-internal' do
  content "repository.createRubygemsHosted('rubygems-internal');" \
    " repository.createRubygemsProxy('rubygems-org','https://rubygems.org/');" \
    " repository.createRubygemsGroup('rubygems-all',['rubygems-org','rubygems-internal'])"
  action :run
end
