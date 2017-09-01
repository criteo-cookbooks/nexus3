# Nexus3 Cookbook

[![Cookbook Version][cookbook_version]][cookbook]
[![Build Status][build_status]][build_status]

[cookbook]: https://supermarket.chef.io/cookbooks/nexus3
[cookbook_version]: https://img.shields.io/cookbook/v/nexus3.svg
[build_status]: https://api.travis-ci.org/criteo-cookbooks/nexus3.svg?branch=master

This cookbook installs and configures Sonatype Nexus 3 Repository 
Manager OSS according to 
https://books.sonatype.com/nexus-book/reference3/install.html

# Usage

Use the [nexus3](https://github.com/criteo-cookbooks/nexus3#nexus3) resource
to download and install the latest Nexus 3 Repository Manager OSS.

Use the [nexus3_api](https://github.com/criteo-cookbooks/nexus3#nexus3_api)
resource to configure Nexus 3 Repository Manager via its REST API.

Use the [nexus3_repo](https://github.com/criteo-cookbooks/nexus3#nexus3_repo)
resource to configure Nexus 3 repositories.

## Requirements
* Chef 12.14.34+
* ark cookbook
  * Note: `include_recipe 'ark'` is required for Windows servers, as it is not
    implicit.
* Java 8+ from Oracle or OpenJDK (not installed, pick your own)

### Platforms

- CentOS, RedHat, Fedora
- Debian, Ubuntu
- Windows

# Recipes

## default

Downloads and installs the latest Nexus 3 Repository Manager OSS.

### Attributes

- `node['nexus3']['url']` - The download URL of Nexus 3 Repository 
Manager. This can be a specific version of Nexus Repository Manager OSS 
or Nexus Repository Manager Pro.
Default `http://download.sonatype.com/nexus/3/latest-unix.tar.gz`.
- `node['nexus3']['checksum']` (optional) - The checksum of Nexus 
Repository Manager. Default `nil`.
- `node['nexus3']['path']` -  Install directory.
Default Linux: `/opt` Windows: `#{ENV['SYSTEMDRIVE']}`.
- `node['nexus3']['data']` -  Data directory. 
Default `#{node['nexus3']['path']}/sonatype-work/nexus3`.
- `node['nexus3']['home']` -  Link to install directory. 
Default `#{node['nexus3']['path']}/nexus3`.
- `node['nexus3']['properties_cookbook']` -  Cookbook that contains the 
template to use. Default `nexus3`.
- `node['nexus3']['properties_source']` -  Template file that will be 
used to create the `#{data}/etc/nexus.properties`
file. Default `nexus.properties.erb`.
- `node['nexus3']['properties_variables']` -  A Hash of variables that 
are passed into a template file.
Default `{ host: '0.0.0.0', port: '8081', args: '${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-requestlog.xml', context_path: '/' }`.
- `node['nexus3']['vmoptions_cookbook']` -  Cookbook that contains the 
template to use. Default `nexus3`.
- `node['nexus3']['vmoptions_source']` -  Template file that will be 
used to create the `#{home}/bin/nexus.vmoptions`
file. Default `nexus.vmoptions.erb`.
- `node['nexus3']['vmoptions_variables']` -  A Hash of variables that 
are passed into a template file. Note that
data directory will be injected into the hash if it is not defined. 
Default `{ Xms: '1200M', Xmx: '1200M' }`.

### Examples

#### Changing the HTTP Port and/or Context Path
The default value for the HTTP port used to access the repository manager user interface and resources is 8081.
To change HTTP Port to 8443, Context Path to /components/ and serve HTTPS directly set the properties_variables hash with the updated settings:

```ruby
include_recipe 'java_se'

node.default['nexus3']['properties_variables'] = { port: '8443', args: '${jetty.etc}/jetty.xml,${jetty.etc}/jetty-https.xml,${jetty.etc}/jetty-requestlog.xml', context_path: '/components/' }
include_recipe 'nexus3'
```

#### Updating Memory Allocation and other JVM Paramaters
The default and maximum heap sizes for the repository manager are a value of 1200M, suitable for most usage patterns.
To install latest nexus3 with 1500M initial memory and 2G max memory, set it in the vmoptions_variables:

```ruby
include_recipe 'java_se'

node.default['nexus3']['vmoptions_variables'] = { Xms: '1500M', Xmx: '2G' }
include_recipe 'nexus3'
```

# Resources

## nexus3

Downloads and installs the latest Nexus Repository Manager OSS v3.

### Actions
- `:install` - Default and only action. Downloads and installs the latest
  Nexus Repository Manager OSS v3.

### Attributes

- `instance_name` - Name of service. Default value is the name of the resource block.
- `nexus3_user` - The owner of nexus3. Creates a Unix user. Default `node['nexus3']['user']`.
- `nexus3_group` - The group of nexus3. Creates a Unix group. Default
  `node['nexus3']['group']`.
- `nexus3_password` - Password for the admin account on Nexus. Will be set
  during installation. Default 'admin123'; we advise you to set it from a
  Vault in your recipe.
- `version` - The version of Nexus3 to install. Default `node['nexus3']['version']`
- `url` - The download URL of latest Nexus 3 Repository Manager OSS. This can be updated to
download a specific version of Nexus Repository Manager OSS or Nexus Repository Manager Pro.
Default `node['nexus3']['url']`.
- `checksum` (optional) - The checksum of Nexus Repository Manager. Default `node['nexus3']['checksum']`.
- `nexus3_home` - The Unix homedir of the nexus3 user. Default `node['nexus3']['home']`.
- `path` -  Install directory. Default `node['nexus3']['path']`.
- `data` -  Data directory. Default `node['nexus3']['data']`.
- `properties_variables` - A Hash of variables that are passed into a template
  file. Default `node['nexus3']['properties_variables']`.
- `vmoptions_variables` - A Hash of variables that are passed into a template
  file. Note that data directory will be injected into the hash if it is not
  defined. Default `node['nexus3']['vmoptions_variables']`.

### Examples

#### Changing the HTTP Port and/or Context Path and/or HTTP vs HTTPS
The default value for the HTTP port used to access the repository manager user interface and resources is 8081.
To change HTTP Port to 8443, Context Path to /components/ and serve HTTPS directly, set the properties_variables hash with the updated settings:

```ruby
include_recipe 'java_se'

nexus3 'nexus' do
  properties_variables(
    host: '0.0.0.0',
    port: '8443',
    args: '${jetty.etc}/jetty.xml,${jetty.etc}/jetty-https.xml,${jetty.etc}/jetty-requestlog.xml',
    context_path: '/components/'
  )
  action :install
end
```

#### Updating Memory Allocation and other JVM Paramaters
The default and maximum heap sizes for the repository manager are a value of 1200M, suitable for most usage patterns.
To install latest nexus3 with 1500M initial memory and 2G max memory, set it in the vmoptions_variable:

```ruby
include_recipe 'java_se'

nexus3 'nexus' do
  vmoptions_variables(
    Xms: '1500M',
    Xmx: '2G'
  )
  action :install
end
```

## nexus3_api

Configures Nexus 3 Repository Manager via API.

### Actions
- `:run` - Default. Run the named script on the repository manager. The script
  must already have been created.
- `:create` - Creates or updates the named script on the repository manager
  (default action).
- `:delete` - Deletes the named script from the repository manager.

### Properties

- `script_name` - Name of script. Default value is the name of the resource block.
- `content` - Content of script. This is usually Groovy, see [Sonatype Nexus 3
  documentation](https://books.sonatype.com/nexus-book/3.1/reference/scripting.html) for
  more information, or see the example scripts in the `repo` resource.
- `args` - Hash or Array arguments passed when `:run` is called.
- `endpoint` - REST API endpoint. Default `node['nexus3']['api']['endpoint']`.
- `username` - Username to run the script as. Default `admin`.
- `password` - Password of username.  Default `admin123`.
- `script_cookbook` - Cookbook that contains the file to use. Default `node['nexus3']['api']['script_cookbook']`.
- `script_source` - Name of the file in `#{script_cookbook}/files/default` or the path to a file located
in `#{script_cookbook}/files`. The path must include the file name and its extension. . Default `nil`.

### Examples

See [api_examples](https://github.com/criteo-cookbooks/nexus3/tree/master/api_examples) for more examples of using
*nexus3_api* resource to configure Nexus Repository Manager.  Pull Requests improving or adding additional
API Examples are welcome and encouraged.

#### Simple repository creation script

Creates or updates private script on Nexus 3 Repository Manager, then runs the script.

```ruby
nexus3_api 'private' do
  content "repository.createMavenHosted('private')"
  action :run
end
```

## nexus3_repo

Configures Nexus 3 repositories via API.

### Actions
- `:create` - Creates or updates a repository, passing a configuration via
  `args`.
- `:delete` - Deletes a repository.

### Properties
- `repo_name` - Name of repository to act on, defaults to resource attribute name.
- `repo_type` - Type (or recipe in Nexus 3 words) of repository to create,
  among `maven2-hosted`, `maven2-proxy`, 'npm-hosted`, ... (default: 'maven2-hosted')
- `attributes` - Hash of attributes passed to the `:create` action, used to
  specify repository attributes for creation or update.
- `online` - Whether to put the repository online or not (default: true).
- `api_url` - Nexus 3 API endpoint (default: node['nexus3']['api']['endpoint']).
- `api_user` - Nexus 3 API user name (default: 'admin').
- `api_password` - Nexus 3 API password (default: 'admin123').

## nexus3_admin

This resource consists for now of a single action used to change a user's
password. Since no other method is available to create users for now, it is
not very useful

Changing the admin password is supported right after installation

### Actions
- `:run` - Updates the password.

### Properties
- `username` - Username to change password for. Defaults to 'admin'.
- `new_password` - New password to set.
- `api_url` - Nexus 3 API endpoint (default: node['nexus3']['api']['endpoint']).
- `api_user` - Nexus 3 API user name (default: 'admin').
- `api_password` - Nexus 3 API password (default: 'admin123').

## ChefSpec Matchers

The nexus3 cookbook includes custom [ChefSpec](https://github.com/sethvargo/chefspec) matchers you can use to test
your own cookbooks.

Example Matcher Usage

```ruby
expect(chef_run).to install_nexus('nexus').with(
  data: '/opt/repository/data'
)
```

Nexus3 Cookbook Matchers

- install_nexus3(resource_name)
- uninstall_nexus3(resource_name)
- run_nexus3_api(resource_name)
- create_nexus3_api(resource_name)
- delete_nexus3_api(resource_name)
- list_nexus3_api(resource_name)
- create_nexus3_repo(resource_name)
- delete_nexus3_repo(resource_name)

## Getting Help

- Ask specific questions on [Stack Overflow](http://stackoverflow.com/questions/tagged/nexus3).
- Report bugs and discuss potential features in [Github issues](https://github.com/criteo-cookbooks/nexus3/issues).

## Contributing

Please refer to [CONTRIBUTING](https://github.com/criteo-cookbooks/nexus3/blob/master/CONTRIBUTING.md).

## License and Authors

Authors: [Denis Hoer](https://github.com/dhoer) (<dennis.hoer@gmail.com>)

License: MIT - see the accompanying [LICENSE](https://github.com/criteo-cookbooks/nexus3/blob/master/LICENSE.md) file for details.
