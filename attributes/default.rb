# frozen_string_literal: true
#
# Cookbook Name:: newrelic_redis_plugin
# Attributes:: default
#
# Copyright 2016, ECHO Inc
#

default['newrelic_redis_plugin']['newrelic_license_key'] = nil
default['newrelic_redis_plugin']['ruby_interpreter'] = '/usr/bin/env ruby'
default['newrelic_redis_plugin']['newrelic_user'] = 'newrelic'
default['newrelic_redis_plugin']['newrelic_group'] = 'newrelic'
default['newrelic_redis_plugin']['install_path'] = '/opt/newrelic_redis_plugin'
default['newrelic_redis_plugin']['pid_file_path'] = '/var/run/newrelic_redis_plugin'
default['newrelic_redis_plugin']['log_file_path'] = '/var/log/newrelic_redis_plugin'

default['newrelic_redis_plugin']['agent_guid'] = 'net.kenjij.newrelic_redis_plugin'
default['newrelic_redis_plugin']['agent_version'] = '1.0.1'

default['newrelic_redis_plugin']['instances'] = [
  {
    name: nil,
    url: 'redis://localhost:6379',
    database: nil
  }
]
