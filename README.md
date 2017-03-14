# Nexus3 Cookbook

[![Cookbook Version](http://img.shields.io/cookbook/v/nexus3.svg?style=flat-square)][cookbook]
[![linux](http://img.shields.io/travis/dhoer/chef-nexus3/master.svg?label=linux&style=flat-square)][linux]
[![win](https://img.shields.io/appveyor/ci/dhoer/chef-nexus3/master.svg?label=windows&style=flat-square)][win]

[cookbook]: https://supermarket.chef.io/cookbooks/nexus3
[linux]: https://travis-ci.org/dhoer/chef-nexus3
[win]: https://ci.appveyor.com/project/dhoer/chef-nexus3


This cookbook installs and configures Sonatype Nexus 3 Repository 
Manager OSS according to 
https://books.sonatype.com/nexus-book/reference3/install.html

# Usage

Include [default](https://github.com/dhoer/chef-nexus3#default) recipe or use
[nexus3](https://github.com/dhoer/chef-nexus3#nexus3) resource to download and install
the latest Nexus 3 Repository Manager OSS.
Use [nexus3_api](https://github.com/dhoer/chef-nexus3#nexus3_api) resource to configure Nexus 3 Repository Manager.

## Requirements
* Chef 12+
* Java 8+ from Oracle (Java is not installed by this cookbook and OpenJDK is not supported)

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
- `:install` - Default. Downloads and installs the latest Nexus Repository Manager OSS v3.  
- `:uninstall` - Removes service and install directory. Uninstall will not delete the data directory unless the default
data configuration has changed to place it under the install directory (which is not recommended).
- `:nothing` - Define this resource block to do nothing until notified by another resource to take action.
When this resource is notified, this resource block is either run immediately or it is queued up to be run
at the end of the chef-client run.

### Attributes

- `servicename` - Name of service. Default value is the name of the resource block.
- `user` - The owner of nexus3. Creates a nexus user when nil or uses value passed in. Default `nil`.
- `group` - The group of nexus3. Creates a nexus group when nil or uses value passed in. Default `nil`.
- `url` - The download URL of latest Nexus 3 Repository Manager OSS. This can be updated to
download a specific version of Nexus Repository Manager OSS or Nexus Repository Manager Pro.
Default `node['nexus3']['url']`.
- `checksum` (optional) - The checksum of Nexus Repository Manager. Default `node['nexus3']['checksum']`.
- `data` -  Data directory. Default `node['nexus3']['data']`.
- `path` -  Install directory. Default `node['nexus3']['path']`.
- `home` -  Link to install directory. Default `node['nexus3']['home']`.
- `properties_cookbook` -  Cookbook that contains the template to use. Default `node['nexus3']['properties_cookbook']`.
- `properties_source` -  Template file that will be used to create the `#{data}/etc/nexus.properties`
file. Default `node['nexus3']['properties_source']`.
- `properties_variables` -  A Hash of variables that are passed into a template file.
Default `node['nexus3']['properties_variables']`.
- `vmoptions_cookbook` -  Cookbook that contains the template to use. Default `node['nexus3']['vmoptions_cookbook']`.
- `vmoptions_source` -  Template file that will be used to create the `#{home}/bin/nexus.vmoptions`
file. Default `node['nexus3']['vmoptions_source']`.
- `vmoptions_variables` -  A Hash of variables that are passed into a template file. Note that data directory will
be injected into the hash if it is not defined. Default `node['nexus3']['vmoptions_variables']`.

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
- `:run` - Default. Run the script on repository manager. If script_source or content attribute is
provided, the script will be created or updated on repository manager before running.
- `:create` - Creates or updates script on repository manager.
- `:delete` - Deletes script from repository manager.
- `:list` - Returns a list of scripts, including content, stored on the repository manager. If the script name matches
resource name, then only its script content is returned from repository manager.  
- `:nothing` - Define this resource block to do nothing until notified by another resource to take action.
When this resource is notified, this resource block is either run immediately or it is queued up to be run
at the end of the chef-client run.

### Attributes

- `script_name` - Name of script. Default value is the name of the resource block.
- `username` - Username to run the script as. Default `admin`.
- `password` - Password of username.  Default `admin123`.  
- `content` - Content of script. Ignored if script_source attribute provided. Default `nil`.
- `script_cookbook` - Cookbook that contains the file to use. Default `node['nexus3']['api']['script_cookbook']`.
- `script_source` - Name of the file in `#{script_cookbook}/files/default` or the path to a file located
in `#{script_cookbook}/files`. The path must include the file name and its extension. . Default `nil`.
- `args` - String argument or Array of arguments to be used in script. Default `nil`.
- `type` - Type of script. Default `node['nexus3']['api']['type']`.
- `host` - Nexus host url (including port if necessary). Default `node['nexus3']['api']['host']`.
- `endpoint` - REST API endpoint. Default `node['nexus3']['api']['endpoint']`.
- `ignore_failure` - Fail silently on script errors. This is mostly done to enable scripts to better deal with
failed attempts, e.g., creating a repo that already exists. Default `node['nexus3']['api']['ignore_failure']`.
- `live_stream` - Use for debugging REST API output. Output suppressed when sensitive is true.
Default `node['nexus3']['api']['live_stream']`.
- `wait` - Wait time in seconds for Nexus Rest API endpoint to come up. Default `node['nexus3']['api']['wait']`.
- `sensitive` - Suppress output. Default `node['nexus3']['api']['sensitive']`.

### Examples

See [api_examples](https://github.com/dhoer/chef-nexus3/tree/master/api_examples) for more examples of using
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

## Getting Help

- Ask specific questions on [Stack Overflow](http://stackoverflow.com/questions/tagged/nexus3).
- Report bugs and discuss potential features in [Github issues](https://github.com/dhoer/chef-nexus3/issues).

## Contributing

Please refer to [CONTRIBUTING](https://github.com/dhoer/chef-nexus3/blob/master/CONTRIBUTING.md).

## License

MIT - see the accompanying [LICENSE](https://github.com/dhoer/chef-nexus3/blob/master/LICENSE.md) file for details.
