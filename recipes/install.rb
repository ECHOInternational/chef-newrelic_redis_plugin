# frozen_string_literal: true
#
# Cookbook Name:: newrelic_redis_plugin
# Recipe:: install
#
# Copyright (c) 2016 ECHO Inc, All Rights Reserved.

gem_package 'bundler'
gem_package 'dante'
gem_package 'newrelic_plugin'
gem_package 'redis'

directory node['newrelic_redis_plugin']['install_path'] do
  owner node['newrelic_redis_plugin']['newrelic_user']
  group node['newrelic_redis_plugin']['newrelic_group']
  action :create
end

directory node['newrelic_redis_plugin']['pid_file_path'] do
  owner node['newrelic_redis_plugin']['newrelic_user']
  group node['newrelic_redis_plugin']['newrelic_group']
  action :create
end

directory node['newrelic_redis_plugin']['log_file_path'] do
  owner node['newrelic_redis_plugin']['newrelic_user']
  group node['newrelic_redis_plugin']['newrelic_group']
  action :create
end

node['newrelic_redis_plugin']['instances'].each do |instance|
  if instance[:name].nil?
    uri = URI.parse(instance['url'])
    host_name = uri.host
    instance_name = "#{host_name}_#{uri.port}"
  else
    instance_name = instance[:name]
  end

  template_file = "#{node['newrelic_redis_plugin']['install_path']}/#{instance_name}"
  pid_file = "#{node['newrelic_redis_plugin']['pid_file_path']}/#{instance_name}.pid"
  log_file = "#{node['newrelic_redis_plugin']['log_file_path']}/#{instance_name}.log"

  # Create Daemon Script From Template
  template template_file do
    source ::File.join('default', 'newrelic_redis_agent.erb')
    owner node['newrelic_redis_plugin']['newrelic_user']
    group node['newrelic_redis_plugin']['newrelic_group']
    mode '0754'
    variables(
      pid_file: pid_file,
      log_file: log_file,
      instance_name: instance_name,
      instance_url: instance[:url],
      instance_database: instance[:database]
    )
  end

  service_name = "newrelic_#{instance_name}"
  init_script_template_file = "/etc/init.d/#{service_name}"
  # Create Daemon Script From Template
  template init_script_template_file do
    source ::File.join('default', 'init_script.erb')
    owner 'root'
    group 'root'
    mode '0755'
    variables(
      pid_file: pid_file,
      log_file: log_file,
      cmd_file: template_file,
      service_name: service_name,
      instance_name: instance_name
    )
  end
end
