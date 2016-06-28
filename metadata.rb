# frozen_string_literal: true
name 'newrelic_redis_plugin'
maintainer 'ECHO Inc'
maintainer_email 'nflood@echonet.org'
license 'MIT'
description 'Installs/Configures a Redis monitoring plugin for Newrelic'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'
source_url 'https://github.com/ECHOInternational/chef-newrelic_redis_plugin'
issues_url 'https://github.com/ECHOInternational/chef-newrelic_redis_plugin/issues'

supports 'ubuntu'
supports 'debian'
supports 'centos'
supports 'amazon'
