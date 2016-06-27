# frozen_string_literal: true
#
# Cookbook Name:: newrelic_redis_plugin
# Spec:: default
#
# Copyright (c) 2016 ECHO Inc, All Rights Reserved.

require 'spec_helper'

describe 'newrelic_redis_plugin::enable' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'enables the service' do
      expect(chef_run).to enable_service('newrelic_localhost_6379')
    end

    it 'starts the service' do
      expect(chef_run).to start_service('newrelic_localhost_6379')
    end
  end
  context 'When multiple instances are specified' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new do |node|
        node.set['newrelic_redis_plugin']['instances'] = [
          {
            name:   'custom_name_A',
            url:    'redis://localhost:6382',
            database: 'dbA'
          },
          {
            name:   'custom_name_B',
            url:    'redis://localhost:6383',
            database: 'dbB'
          }
        ]
      end
      runner.converge(described_recipe)
    end
    it 'enables all services' do
      expect(chef_run).to enable_service('newrelic_custom_name_A')
      expect(chef_run).to enable_service('newrelic_custom_name_B')
    end
    it 'starts all services' do
      expect(chef_run).to start_service('newrelic_custom_name_A')
      expect(chef_run).to start_service('newrelic_custom_name_B')
    end
  end
end
