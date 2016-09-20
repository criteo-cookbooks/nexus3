# create and run pypi hosted, proxy and group repositories
nexus3_api 'pypi-internal' do
  content "repository.createPyPiHosted('pypi-internal');" \
    " repository.createPyPiProxy('pypi-python-org','https://pypi.python.org/');" \
    " repository.createPyPiGroup('pypi-all',['pypi-python-org','pypi-internal'])"
  action :run
end
