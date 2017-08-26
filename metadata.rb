name 'nexus3'
maintainer 'Dennis Hoer'
maintainer_email 'dennis.hoer@gmail.com'
license 'MIT'
description 'Installs/Configures Sonatype Nexus 3 Repository Manager'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://github.com/dhoer/chef-nexus3' if respond_to?(:source_url)
issues_url 'https://github.com/dhoer/chef-nexus3/issues' if respond_to?(:issues_url)
version '2.1.1'

chef_version '>= 12.0'

supports 'centos'
supports 'debian'
supports 'fedora'
supports 'redhat'
supports 'ubuntu'
supports 'windows'
