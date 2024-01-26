default['nexus3']['api']['username'] = 'admin'
default['nexus3']['api']['password'] = 'admin123'
default['nexus3']['api']['endpoint'] = 'http://localhost:8081/service/rest/v1/'

default['nexus3']['plugins']['repository_cargo']['name'] = 'nexus-repository-cargo'
default['nexus3']['plugins']['repository_cargo']['action'] = 'create'
default['nexus3']['plugins']['repository_cargo']['source'] = 'https://github.com/jeremy-clerc/nexus-repository-cargo/releases/download/' \
                                                             'v0.0.8/nexus-repository-cargo-0.0.8-bundle.kar'
default['nexus3']['plugins']['repository_cargo']['checksum'] = '8e88aafc8b44eaf9d3ddb4350b943e37379119dab631deb52f3cf027a134b81d'
