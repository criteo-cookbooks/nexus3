# Nexus3 Cookbook

[![Cookbook Version][cookbook_version]][cookbook]
[![Build Status][build_status]][build_status]

[cookbook]: https://supermarket.chef.io/cookbooks/nexus3
[cookbook_version]: https://img.shields.io/cookbook/v/nexus3.svg
[build_status]: https://img.shields.io/github/actions/workflow/status/criteo-cookbooks/nexus3/criteo-cookbooks-ci.yml

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

Use the [nexus3_group](https://github.com/criteo-cookbooks/nexus3#nexus3_group)
resource to configure Nexus 3 repository groups.

Use the [nexus3_user](https://github.com/criteo-cookbooks/nexus3#nexus3_user)
resource to configure Nexus 3 users.

Use the [nexus3_realm](https://github.com/criteo-cookbooks/nexus3#nexus3_realm)
resource to handle realm activation.

Use the [nexus3_routing_rule](https://github.com/criteo-cookbooks/nexus3#nexus3_routing_rule)
resource to configure Nexus 3 routing rules.

Use the [nexus3_component](https://github.com/criteo-cookbooks/nexus3#nexus3_component)
resource to create a component / upload an asset.

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

- `node['nexus3']['version']` - The version of Nexus 3 to download. Default
  `3.2.1-01`.
- `node['nexus3']['url']` - The download URL of Nexus 3 Repository Manager.
  This can be a specific version of Nexus Repository Manager OSS or Nexus
  Repository Manager Pro. Default
  `http://download.sonatype.com/nexus/3/nexus-3.2.1-01-unix.tar.gz`.
- `node['nexus3']['checksum']` (optional) - The checksum of Nexus 
  Repository Manager. Default `nil`.
- `node['nexus3']['path']` -  Install directory.
  Default Linux: `/opt` Windows: `#{ENV['SYSTEMDRIVE']}`.
- `node['nexus3']['data']` -  Data directory. 
  Default `#{node['nexus3']['path']}/sonatype-work/nexus3`.
- `node['nexus3']['home']` -  Link to install directory. 
  Default `#{node['nexus3']['path']}/nexus3`.
- `node['nexus3']['properties_variables']` - A Hash of variables that are
  passed into a file populated on each line with the following format: 
  'Key'='Value'.
  Default `{ 'application-host': '0.0.0.0', 'application-port': '8081', 'nexus-args':
  '${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-requestlog.xml',
  'nexus-context-path': '/' }`.
- `node['nexus3']['desired_heap_size']` - To easily configure the min & max heap size (JVM Xms & Xmx). Default `'4G'`.
- `node['nexus3']['vmoptions_variables']` - A Hash of variables that are
  passed into a template file. Note that data directory will be injected into
  the hash if it is not defined and Xms & Xmx variables are managed by `desired_heap_size`. Default `{ Xms: '4G', Xmx: '4G' }`.
- `node['nexus3']['nofile_limit']` - Limit of open files available for the
  Nexus3 service in systemd. Default 65,536 as suggested by the Sonatype
  documentation on newer releases.
- `node['nexus3']['outbound_proxy']` - Configure outbound HTTP/HTTPS proxy. See example
  'Configure outbound HTTP/HTTPS proxy for all the attributes.'

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

The default and maximum heap sizes for the repository manager are a value of
1200 MB, suitable for most usage patterns. To install latest nexus3 with 1500 MB
initial memory and 2 GB max memory, set it in the `vmoptions_variables`:

```ruby
include_recipe 'java_se'

node.default['nexus3']['vmoptions_variables'] = { Xms1500M: nil, Xmx2G: nil }
include_recipe 'nexus3'
```

The `vmoptions_variables` attributes are mapped to JVM options `-<key>=<value>` if a value
is defined. If `<value>` is `nil`, the option becomes `-<key>`.

#### Configure outbound HTTP/HTTPS proxy

```ruby
node.default['nexus3']['outbound_proxy'] = {
  'http' => {
    'host' => 'proxy.example.com',
    'port' => 80,
    'auth' => {
      'username' => 'example',
      'password' => 'secret',
      'host' => 'NTLM host',
      'domain' => 'NTLM domain',
    },
  },
  'https' => {
    'host' => 'proxy.example.com',
    'port' => 80,
    'auth' => {
      'username' => 'example',
      'password' => 'secret',
      'host' => 'NTLM host',
      'domain' => 'NTLM domain',
    },
  },
  'non_proxy_hosts' => ['rubygems.org', '*.chef.io'],
}
```

`http` is mandatory, it is a prerequisite to configure the outbound proxy,
you cannot just configure `https` for example, it would not be valid.

`auth` can be ommited if you do not want to configure authentication. Only set
`username` and `password` for basic authentication, else it will be NTLM.

# Resources

## Properties common to all resources using the Nexus3 API

`api_client` - A ::Nexus3::Api instance. Default is configured using
following `nexus3.api` attributes: `endpoint`, `username` & `password`

## nexus3

Downloads and installs the latest Nexus Repository Manager OSS v3.

### Actions
- `:install` - Default. Downloads and installs the latest Nexus Repository Manager OSS v3.

Since the installation is resource-based, you can install different Nexus3
instances on the same node. Make sure to specify different home and data
directories, as well as different port numbers.

### Attributes

- `instance_name` - Name of service. Default value is the name of the resource
  block.
- `nexus3_user` - The owner of nexus3. Creates a nexus user with the value
  passed in. Default `node['nexus3']['user']`.
- `nexus3_group` - The group of nexus3. Creates a nexus group with the value
  passed in. Default `node['nexus3']['group']`.
- `version` - Version of Nexus3 to install. Default
  `node['nexus3']['version']`
- `url` - The download URL of latest Nexus 3 Repository Manager OSS. This can
  be updated to download a specific version of Nexus Repository Manager OSS or
  Nexus Repository Manager Pro. Default `node['nexus3']['url']`.
- `checksum` (optional) - The checksum of Nexus Repository Manager. Default
  `node['nexus3']['checksum']`.
- `data` -  Data directory. Default `node['nexus3']['data']`.
- `path` -  Install directory. Default `node['nexus3']['path']`.
- `nexus3_home` - Link to install directory. Default `node['nexus3']['home']`.
- `service_name` - Name of service used for the system service manager
  (systemd or other). Defaults to `instance_name`.
- `properties_variables` - A Hash of variables that are passed into a template
  file. Default `node['nexus3']['properties_variables']`.
- `vmoptions_variables` - A Hash of variables that are passed into a template
  file. Note that data directory will be injected into the hash if it is not
  defined. Default `node['nexus3']['vmoptions_variables']`.
- `outbound_proxy` - Configure outbound HTTP/HTTPS proxy. Default `node['nexus3']['outbound_proxy']`.

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

Configures Nexus 3 Repository Manager via Script API. Low-level resource,
usually used within other resources.

### Actions
- `:create` - Creates or updates the named script on the repository manager
  (default action).
- `:run` - Runs the named script on the repository manager. The script must
  already have been created.
- `:delete` - Deletes the named script from the repository manager.

### Properties

- `script_name` - Name of script. Default value is the name of the resource block.
- `content` - Content of script. This is usually Groovy, see [Sonatype Nexus 3
  documentation](https://books.sonatype.com/nexus-book/3.1/reference/scripting.html) for
  more information, or see the example scripts in the `repo` resource.
- `args` - Hash, String or NilClass arguments passed when `:run` is called.

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

Configures Nexus 3 repositories via API. This works by calling a Groovy script
which will trigger the creation, update or deletion of a given repository. For
ease of reading the source code, scripts are stored under `files/default` with
the help of `libraries/scripts_helper.rb`.

### Actions
- `:create` - Creates or updates a repository, passing a configuration via
  `args`.
- `:delete` - Deletes a repository.

### Properties
- `repo_name` - Name of repository to act on, defaults to resource property
  name.
- `repo_type` - Type (or recipe in Nexus 3 words) of repository to create,
  among `maven2-hosted`, `maven2-proxy`, 'npm-hosted`, ... (default: 'maven2-hosted')
- `attributes` - Hash of attributes passed to the `:create` action, used to
  specify repository attributes for creation or update.
- `online` - Whether to put the repository online or not (default: true).

## nexus3_task

Configures scheduled tasks via API.

### Actions

- `:create` - Creates or updates a scheduled task.
- `:delete` - Removes a scheduled task.

### Properties

- `task_name` - Name of task to act on, defaults to resource name.
- `task_source` - Source code of the script to run, for now it defaults to
  running Groovy scripts (typeID: script).
- `task_crontab` - Actual schedule in the form of a crontab string.

## nexus3_realm

Handle realm activation via API.

### Actions

- `:configure` - Configure a given realm.

### Properties

- `realm_name` - Name of realm to act on, defaults to resource name.
- `enable` - Whether to enable a given realm.

## nexus3_routing_rule

Configures Nexus 3 [routing rules](https://help.sonatype.com/repomanager3/repository-management/routing-rules)
via the REST API. Routing rules are used to restrict certain paths
on proxy repositories.

### Actions

- `:create` - Creates or updates a routing rule.
- `:delete` - Deletes a routing rule.

### Properties

- `description` - Rule description.
- `mode` - Rule mode to ALLOW or BLOCK the given matchers, defaults to BLOCK.
- `matchers` - A list of regex to identify paths to allow / block.

## nexus3_group

Configures Nexus 3 repository groups via API. This works wrapping the nexus3_repo
resource with names of member repositories added as an attribute.

### Actions
- `:create` - Creates or updates a group, passing a configuration via `attributes`.
- `:delete` - Deletes a group.

### Properties
- `group_name` - Name of repository group to act on, defaults to resource property
  name.
- `group_type` - Type (or recipe in Nexus 3 words) of repository group to create,
  among `maven2-group`, 'npm-group`, ... (default: 'maven2-group')
- `attributes` - Hash of attributes passed to the `:create` action, used to
  specify repository attributes for creation or update.
- `online` - Whether to put the repository online or not (default: true).
- `repositories` - Array of repository names that compose the group.

## nexus3_user

Configures users for use with Nexus3. Users can be assigned roles and
privileges, which are seen in the `nexus3_role` resource.

### Actions

- `:create` - Creates or updates a user. You can change a non-admin user's
  password with this resource. You will have to use a (yet to be written)
  `nexus3_admin_password` resource to update the current admin password.
- `:delete` - Deletes a user.

### Properties

- `username` - Username to create, defaults to resource name.
- `password` - Password of user.
- `first_name` - User first name.
- `last_name` - User last name.
- `email` - User email address.
- `roles` - Array of roles to assign to the user (either the default ones or
  those added with the `nexus3_role` resource).

## nexus3_role

Configures roles to use with Nexus3, so you can assign users to these roles
later. Roles are associated with a list of privileges defined by Nexus3 and
can be nested.

### Actions

- `:create` - Creates or updates a role.
- `:delete` - Deletes a role.

### Properties

- `role_name` - Name of role to update, defaults to resource name.
- `description` - A free-form description of the role.
- `roles` - Array of roles that are part of this role. If any role does not
  exist, it will be ignored if you use the script provided.
- `privileges` - Array of privileges defined in Nexus3.

## nexus3_cleanup_policy

Configures Cleanup Policy to use with Nexus3 repositories, so you can configure
rentention limit. Policies are per repository format and relative to either the
artifact's publish_date or its last download date.

### Actions

- `:create` - Creates or updates a policy.
- `:delete` - Deletes a policy.

### Properties

- `policy_name` - Name of the policy to manage, defaults to resource name.
- `notes` - A small description about the cleanup policy.
- `format` - The target repository format, defaults to 'raw'.
- `mode` - Cleanup mode, currently only 'delete' seems to be supported.
- `criteria` - Hash of rules to control the cleanup.

### Criteria rules

Supported criteria may vary depending on the repository format, but the 2 main ones are:
- `lastBlobUpdated` - Cleanup artifacts published more than the given number of seconds ago.
- `lastDownloaded` - Cleanup artifacts last downloaded more than the given number of seconds ago.

_*NB:* criteria is the number of seconds as String._

### Example

```ruby
nexus3_cleanup_policy 'example' do
  format 'raw'
  notes  'Cleanup all artifacts uploaded more 7 days ago AND last downloaded more than 3 days ago.'
  criteria lastBlobUpdated: '604800', lastDownloaded: '259200'
end
```

## nexus3_component

Create a component / upload an asset to a given repository.
Currently supports Maven2, Raw and Rubygems repositories.

### Actions

- `:create` - Creates a component.

### Properties

- `component_name` - Component name, use as is for maven2.artifactId / raw.asset1.filename
- `type` - Type of asset (linked to repo type), maven2, raw, rubygems
- `repo` - Repository
- `asset` - Path to a file on the machine to upload

When uploading a maven2 asset:

- `maven2_asset_extension` - Asset extension, e.g. jar
- `maven2_asset_classifier` - (Optional) Asset classifier, e.g. uber
- `maven2_version` - Component version
- `maven2_group_id` - Component group ID, e.g. com.example

When uploading a raw asset:

- `raw_directory` - Asset remote path / directory

## Getting Help

- Ask specific questions on [Stack Overflow](http://stackoverflow.com/questions/tagged/nexus3).
- Report bugs and discuss potential features in [Github issues](https://github.com/criteo-cookbooks/nexus3/issues).

## Contributing

Please refer to [CONTRIBUTING](https://github.com/criteo-cookbooks/nexus3/blob/master/CONTRIBUTING.md).

## License and Authors

Authors: [Denis Hoer](https://github.com/dhoer) (<dennis.hoer@gmail.com>)

License: MIT - see the accompanying [LICENSE](https://github.com/criteo-cookbooks/nexus3/blob/master/LICENSE.md) file for details.
