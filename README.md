# Nexus3 Cookbook

[![Cookbook Version](http://img.shields.io/cookbook/v/nexus3.svg?style=flat-square)][cookbook]
[![linux](http://img.shields.io/travis/dhoer/chef-nexus3/master.svg?label=linux&style=flat-square)][linux]

[cookbook]: https://supermarket.chef.io/cookbooks/nexus3
[linux]: https://travis-ci.org/dhoer/chef-nexus3/branches

This cookbook installs and configures Nexus 3 Repository Manager OSS (http://www.sonatype.com/download-oss-sonatype).

# Usage

Include [default](https://github.com/dhoer/chef-nexus3#default) recipe or use 
[nexus3](https://github.com/dhoer/chef-nexus3#nexus3) resource to download and install 
the latest Nexus 3 Repository Manager OSS.

## Requirements

Nexus Repository Manager requires a Java 8 Runtime Environment (JRE) from Oracle which is not included in this cookbook.
 
### Platforms

- CentOS, RedHat, Fedora
- Debian, Ubuntu

# Recipes

## default

Downloads and installs the latest Nexus 3 Repository Manager OSS.

### Attributes

- `node['nexus3']['url']` - The download URL of latest Nexus 3 Repository Manager OSS. This can be updated to
download a specific version of Nexus Repository Manager OSS or Nexus Repository Manager Pro. 
Default `http://download.sonatype.com/nexus/3/latest-unix.tar.gz`.
- `node['nexus3']['checksum']` (optional) - The checksum of Nexus Repository Manager. Default `nil`.
- `node['nexus3']['data']` -  Data directory. Default `/opt/repository/data`.
- `node['nexus3']['root']` -  Root directory. Default `/opt/nexus`.
- `node['nexus3']['home']` -  Link to install directory. Default `#{node['nexus3']['root']}/nexus3`.
- `node['nexus3']['cfg_cookbook']` -  Cookbook that contains the template to use. Default `nexus3`.
- `node['nexus3']['cfg_source']` -  Template file that will be used to create the `#{home}/bin/org.sonatype.nexus.cfg` 
file. Default `org.sonatype.nexus.cfg.erb`.
- `node['nexus3']['cfg_variables']` -  A Hash of variables that are passed into a template file. 
Default `{ port: '8081', context_path: '/' }`.
- `node['nexus3']['vmoptions']` -  Array of application startup options used to create the 
`#{home}/bin/nexus.vmoptions` file. Default `['-Xms1200M',
   '-Xmx1200M',
   '-XX:+UnlockDiagnosticVMOptions',
   '-XX:+UnsyncloadClass',
   '-Djava.net.preferIPv4Stack=true',
   '-Dkaraf.home=.',
   '-Dkaraf.base=.',
   '-Dkaraf.etc=etc',
   '-Djava.util.logging.config.file=etc/java.util.logging.properties',
   "-Dkaraf.data=#{node['nexus3']['data']}",
   "-Djava.io.tmpdir=#{node['nexus3']['data']}/tmp",
   '-Dkaraf.startLocalConsole=false']`.

### Examples

#### Changing the HTTP Port and/or Context Path
The default value for the HTTP port used to access the repository manager user interface and resources is 8081. 
To change HTTP Port and Context Path as 9081 and /components/, set the cfg_variables hash with the updated settings:

```ruby
include_recipe 'java_se'

node.default['nexus3']['cfg_variables'] = { port: '9081', context_path: '/components/' }
include_recipe 'nexus3'
```

#### Updating Memory Allocation and other JVM Paramaters
The default and maximum heap sizes for the repository manager are a value of 1200M, suitable for most usage patterns. 
To install latest nexus3 with 1500M initial memory and 2G max memory, set it in the vmoptions array along with all 
the other settings:

```ruby
include_recipe 'java_se'

node.default['nexus3']['vmoptions'] = [
  '-Xms1500M',
  '-Xmx2G',
  '-XX:+UnlockDiagnosticVMOptions',
  '-XX:+UnsyncloadClass',
  '-Djava.net.preferIPv4Stack=true',
  '-Dkaraf.home=.',
  '-Dkaraf.base=.',
  '-Dkaraf.etc=etc',
  '-Djava.util.logging.config.file=etc/java.util.logging.properties',
  "-Dkaraf.data=#{node['nexus3']['data']}",
  "-Djava.io.tmpdir=#{node['nexus3']['data']}/tmp",
  '-Dkaraf.startLocalConsole=false'
]
include_recipe 'nexus3'
```

# Resources

## nexus3

Downloads and installs the latest Nexus Repository Manager OSS v3.

### Actions
- `:install` - Default. Downloads and installs the latest Nexus Repository Manager OSS v3.  
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
- `root` -  Root directory. Default `node['nexus3']['root']`.
- `home` -  Link to install directory. Default `node['nexus3']['home']`.
- `cfg_cookbook` -  Cookbook that contains the template to use. Default `node['nexus3']['cfg_cookbook']`.
- `cfg_source` -  Template file that will be used to create the `#{home}/bin/org.sonatype.nexus.cfg` 
file. Default `node['nexus3']['cfg_source']`.
- `cfg_variables` -  A Hash of variables that are passed into a template file. 
Default `node['nexus3']['cfg_variables']`.
- `vmoptions` -  Array of application startup options used to create the `#{home}/bin/nexus.vmoptions` file. 
Default `node['nexus3']['vmoptions']`.

### Examples

#### Changing the HTTP Port and/or Context Path
The default value for the HTTP port used to access the repository manager user interface and resources is 8081. 
To change HTTP Port and Context Path as 9081 and /components/, set the cfg_variables hash with the updated settings:

```ruby
include_recipe 'java_se'

nexus3 'nexus' do
  cfg_variables( 
    port: '9081', 
    context_path: '/components/' 
  )
  action :install
end
```

#### Updating Memory Allocation and other JVM Paramaters
The default and maximum heap sizes for the repository manager are a value of 1200M, suitable for most usage patterns. 
To install latest nexus3 with 1500M initial memory and 2G max memory, set it in the vmoptions array along with all 
the other settings:

```ruby
include_recipe 'java_se'

nexus3 'nexus' do
  vmoptions(
    [
      '-Xms1500M',
      '-Xmx2G',
      '-XX:+UnlockDiagnosticVMOptions',
      '-XX:+UnsyncloadClass',
      '-Djava.net.preferIPv4Stack=true',
      '-Dkaraf.home=.',
      '-Dkaraf.base=.',
      '-Dkaraf.etc=etc',
      '-Djava.util.logging.config.file=etc/java.util.logging.properties',
      "-Dkaraf.data=#{data}",
      "-Djava.io.tmpdir=#{data}/tmp",
      '-Dkaraf.startLocalConsole=false'
    ]
  )
  action :install
end
```
      
Nexus3 Cookbook Matchers

- install_nexus3(resource_name)

## Getting Help

- Ask specific questions on [Stack Overflow](http://stackoverflow.com/questions/tagged/nexus).
- Report bugs and discuss potential features in [Github issues](https://github.com/dhoer/chef-nexus3/issues).

## Contributing

Please refer to [CONTRIBUTING](https://github.com/dhoer/chef-nexus3/blob/master/CONTRIBUTING.md).

## License

MIT - see the accompanying [LICENSE](https://github.com/dhoer/chef-nexus3/blob/master/LICENSE.md) file for details.
