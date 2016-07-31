# create and run npm hosted repository
nexus3_api 'npm-internal' do
  content "repository.createNpmHosted('npm-internal');" \
    " repository.createNpmProxy('npmjs-org','https://registry.npmjs.org');" \
    " repository.createNpmGroup('npm-all',['npmjs-org','npm-internal'])"
  action :run
end
