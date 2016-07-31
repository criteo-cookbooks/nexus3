# create and run bower hosted repository
nexus3_api 'bower-internal' do
  content "repository.createBowerHosted('bower-internal');" \
    " repository.createBowerProxy('bower-io','http://bower.herokuapp.com');" \
    " repository.createBowerGroup('bower-all',['bower-io','bower-internal'])"
  action :run
end
