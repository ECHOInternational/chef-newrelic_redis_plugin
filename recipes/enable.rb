# frozen_string_literal: true
#
# Cookbook Name:: newrelic_redis_plugin
# Recipe:: enable
#
# Copyright (c) 2016 ECHO Inc, All Rights Reserved.

node['newrelic_redis_plugin']['instances'].each do |instance|
  if instance[:name].nil?
    uri = URI.parse(instance['url'])
    host_name = uri.host
    instance_name = "#{host_name}_#{uri.port}"
  else
    instance_name = instance[:name]
  end
  service_name = "newrelic_#{instance_name}"

  service service_name do
    supports restart: true, start: true, stop: true, reload: false
    action [:enable, :start]
  end
end
