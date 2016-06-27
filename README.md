# Chef-newrelic_redis_plugin

[![Coverage Status](https://coveralls.io/repos/github/ECHOInternational/chef-newrelic_redis_plugin/badge.svg?branch=master)](https://coveralls.io/github/ECHOInternational/chef-newrelic_redis_plugin?branch=master) [![Build Status](https://travis-ci.org/ECHOInternational/chef-newrelic_redis_plugin.svg?branch=master)](https://travis-ci.org/ECHOInternational/chef-newrelic_redis_plugin) [![Cookbook Version](https://img.shields.io/cookbook/v/newrelic_redis_plugin.svg)](https://community.opscode.com/cookbooks/newrelic_redis_plugin)

Cookbook to install monitoring for Redis servers on Newrelic.

### Credit

These scripts use the newrelic_redis_plugin designed by Ken Jibiki (@kenjij on GitHub)

Plugin Documentation on NewRelic: https://rpm.newrelic.com/accounts/883690/plugins/directory/249

Original scripts on Github: https://github.com/kenjij/newrelic_redis_plugin

Several additional features have been added to the original scripts to make them more useful in unattended install and monitoring situations:

  - Multiple monitoring services can be generated to monitor multiple Redis instances.
  - Generic init.d scripts are implemented to facilitate running the scripts as services.


## Recipes

 - `newrelic_redis_plugin::install`    - This will install the plugin as (a) service(s)
 - `newrelic_redis_plugin::enable`     - This will start the service(s)

## Attributes

### Required Attributes
  - `['newrelic_redis_plugin']['newrelic_license_key']`
    - **_WARNING:_ You must set this value.** You can retrieve your license key from NewRelic at the bottom of [this page](https://rpm.newrelic.com/accounts/883690/plugins/directory/249).
    - **Default:** nil
  - `default['newrelic_redis_plugin']['instances']`
    - An array of parameters for Redis instances to monitor.
    - **Default:** [{name: nil, url: 'redis://localhost:6379', database: nil}]
    - While there is a default value for this attribute, it is likely not what you want for your implementation. Check out the [Examples](#examples) below.

### Optional Attributes
  - `['newrelic_redis_plugin']['ruby_interpreter']`
    - The ruby interpreter that should be used to execute the scripts.
    - **Default:** '/usr/bin/env ruby'
    - **Note:** If no ruby is installed on your server and you have no other reason to install one you can use the one that is bundled into Chef by setting this to '/opt/chef/embedded/bin/ruby'
  - `['newrelic_redis_plugin']['newrelic_user']`
    - User that will own installed files and will run the services. _THIS USER MUST EXIST_ before running the install recipe. This is usually handled by installing Newrelic Server Monitoring before executing these recipes.
    - **Default:** 'newrelic'
  - `['newrelic_redis_plugin']['newrelic_group']`
  - Group that will have access to any installed files. _THIS GROUP MUST EXIST_ before running the install recipe. This is usually handled by installing Newrelic Server Monitoring before executing these recipes.
    - **Default:** 'newrelic'
  - `['newrelic_redis_plugin']['install_path']`
    - Specifies where to create the executable scripts
    - **Default** '/opt/newrelic_redis_plugin'
  - `['newrelic_redis_plugin']['pid_file_path']`
    - Specifies where the service(s) should store PID files
    - **Default:** '/var/run/newrelic_redis_plugin'
  - `['newrelic_redis_plugin']['log_file_path']`
    - Specifies where the service(s) should store log files
    - **Default:** '/var/log/newrelic_redis_plugin'
  - `['newrelic_redis_plugin']['agent_guid']`
    - The agent_guid that identifies which plugin is being utilized on the NewRelic platform. This should only need to be changed if the GUID changes which is outside of the control of this chef recipe.
    - **Default:** 'net.kenjij.newrelic_redis_plugin'
  - `['newrelic_redis_plugin']['agent_version']`
    - The version of the agent that this script is configured to work with. You will likely not change this value.
    - **Default:** '1.0.1'

## Examples

### Single Instance:
```YAML
node['newrelic_redis_plugin']['newrelic_license_key'] = 'YOUR_LICENSE_KEY_HERE'
node['newrelic_redis_plugin']['instances'] = [
  {
    name:     'ExampleInstance',
    url:    'redis://localhost:6379',
    database:   'db0'
  }
]
```
In this example a single monitoring instance will be created to monitor a Redis instance on the local machine at port 6379.

  - The service will be called `ExampleInstance` and will be located at `/opt/newrelic_redis_plugin/ExampleInstance`
  - The PID file will be written to `/var/run/newrelic_redis_plugin/ExampleInstance.pid`
  - Logs will be written to `/var/logs/newrelic_redis_plugin/ExampleInstance.log`
  - Database key metrics will be reported to the "Keyspace" tab for the default database db0.
  - A `newrelic_ExampleInstance` script will be written to `/etc/init.d/newrelic_ExampleInstance` (**NOTE:** This script will be written but NOT started or set to start at boot until the `newrelic_redis_plugin::enable` recipe is run.)
  - Running `service newrelic_ExampleInstance start`, `service newrelic_ExampleInstance stop`, `service newrelic_ExampleInstance restart`, and `service newrelic_ExampleInstance status` should perform all the necessary functions for managing the service.

### Multiple Instances:
```YAML
node['newrelic_redis_plugin']['newrelic_license_key'] = 'YOUR_LICENSE_KEY_HERE'
node['newrelic_redis_plugin']['instances'] = [
  {
    name:     'ExampleInstance_1',
    url:    'redis://localhost:6379',
    database:   'db0'
  },
  {
    name:     'ExampleInstance_2',
    url:    'redis://localhost:6380',
    database:   'db0'
  }
]
```
In this example a two monitoring instances will be created to monitor a Redis instances on the local machine at ports 6379 and 6380.

- The services will be called `ExampleInstance_1` and `ExampleInstance_2` and will be located in the  `/opt/newrelic_redis_plugin` directory
- The PID files will be written to `/var/run/newrelic_redis_plugin`
- Logs will be written to `/var/logs/newrelic_redis_plugin`
- Database key metrics will be reported to the "Keyspace" tab for the default database db0.
- A script will be written to both `/etc/init.d/newrelic_ExampleInstance_1` and `/etc/init.d/newrelic_ExampleInstance_2`
- Running `service newrelic_ExampleInstance_1 start`, `service newrelic_ExampleInstance_1 stop`, `service newrelic_ExampleInstance_1 restart`, and `service newrelic_ExampleInstance_1 status` should perform all the necessary functions for managing the 'ExampleInstance_1' monitoring instance, the same would be true for 'ExampleInstance_2'.

## Design Notes

You should name your monitoring instances something unique and identifiable as this is the name that will be reported on the redis tab of the plugins page on NewRelic. Suggestions could be something like 'ActiveJob_Redis_Production' which would describe the role and environment of the instance.

**DO NOT USE SPACES IN YOUR INSTANCE NAMES**

There is no provision for monitoring multiple databases per instance. You will usually want to just set the `database` setting to 'db0'. Best practices indicate that running multiple databases per instance is not as performant and increases complexity. [The creator of Redis has stated that they are an undesirable way to divide data, and that separate instances should be used instead.](https://groups.google.com/forum/#!topic/redis-db/vS5wX8X4Cjg/discussion)


## Supports
 - Ubuntu
 - CentOS
 - Debian
 - Amazon

## Contributing
Please see CONTRIBUTING for details.


## Copyright & License
Authors:: Nate Flood for ECHO Inc. < [nflood@echonet.org](mailto:nflood@echonet.org) >

License: [MIT](http://echo.mit-license.org/)