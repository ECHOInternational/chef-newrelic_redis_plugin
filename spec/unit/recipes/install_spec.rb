# frozen_string_literal: true
#
# Cookbook Name:: newrelic_redis_plugin
# Spec:: install
#
# Copyright (c) 2016 ECHO Inc, All Rights Reserved.

# rubocop:disable Metrics/LineLength
require 'spec_helper'

describe 'newrelic_redis_plugin::install' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'has default ruby interpreter' do
      expect(chef_run.node['newrelic_redis_plugin']['ruby_interpreter']).to eq('/usr/bin/env ruby')
    end

    it 'installs required gems' do
      expect(chef_run).to install_gem_package('bundler')
      expect(chef_run).to install_gem_package('dante')
      expect(chef_run).to install_gem_package('newrelic_plugin')
      expect(chef_run).to install_gem_package('redis')
    end

    it 'does not have a default Newrelic license key' do
      expect(chef_run.node['newrelic_redis_plugin']['newrelic_license_key']).to be_nil
    end

    it 'has a default newrelic user' do
      expect(chef_run.node['newrelic_redis_plugin']['newrelic_user']).to eq('newrelic')
    end

    it 'has a default newrelic group' do
      expect(chef_run.node['newrelic_redis_plugin']['newrelic_group']).to eq('newrelic')
    end

    it 'has a default install path' do
      expect(chef_run.node['newrelic_redis_plugin']['install_path']).to eq('/opt/newrelic_redis_plugin')
    end

    it 'creates the install directory' do
      expect(chef_run).to create_directory('/opt/newrelic_redis_plugin').with(
        user: 'newrelic',
        group: 'newrelic'
      )
    end

    it 'has a default PID file path' do
      expect(chef_run.node['newrelic_redis_plugin']['pid_file_path']).to eq('/var/run/newrelic_redis_plugin')
    end

    it 'creates the PID file directory' do
      expect(chef_run).to create_directory('/var/run/newrelic_redis_plugin').with(
        user: 'newrelic',
        group: 'newrelic'
      )
    end

    it 'has a default log file path' do
      expect(chef_run.node['newrelic_redis_plugin']['log_file_path']).to eq('/var/log/newrelic_redis_plugin')
    end

    it 'creates the log file directory' do
      expect(chef_run).to create_directory('/var/log/newrelic_redis_plugin').with(
        user: 'newrelic',
        group: 'newrelic'
      )
    end

    it 'has a default instance' do
      expect(chef_run.node['newrelic_redis_plugin']['instances']).to be_a Array
      expect(chef_run.node['newrelic_redis_plugin']['instances'][0]).to be_a Hash
      expect(chef_run.node['newrelic_redis_plugin']['instances'][0]).to have_key :name
      expect(chef_run.node['newrelic_redis_plugin']['instances'][0]).to have_key :url
      expect(chef_run.node['newrelic_redis_plugin']['instances'][0]).to have_key :database
    end

    it 'creates executable script for the default instance' do
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/localhost_6379')
        .with_content('#! /usr/bin/env ruby')
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/localhost_6379')
        .with_content("pid_path = '/var/run/newrelic_redis_plugin/localhost_6379.pid'")
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/localhost_6379')
        .with_content("log_path = '/var/log/newrelic_redis_plugin/localhost_6379.log'")
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/localhost_6379')
        .with_content("runner = Dante::Runner.new('localhost_6379_newrelic_agent', :pid_path  => pid_path, :log_path => log_path)")
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/localhost_6379')
        .with_content('agent_guid "net.kenjij.newrelic_redis_plugin"')
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/localhost_6379')
        .with_content('agent_version "1.0.1"')
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/localhost_6379')
        .with_content('@redis = Redis.new(url: "redis://localhost:6379")')
      expect(chef_run)
        .to_not render_file('/opt/newrelic_redis_plugin/localhost_6379')
        .with_content('dbstat = info["db0"]')
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/localhost_6379')
        .with_content("'newrelic' => {'license_key' => \"\"},")
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/localhost_6379')
        .with_content("'redis' => {'instance_name' => \"localhost_6379\", 'url' => \"redis://localhost:6379\"},")
    end
    it 'creates init script for default instance' do
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_localhost_6379')
        .with_content("\# Provides: newrelic_localhost_6379")
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_localhost_6379')
        .with_content('cmd="/opt/newrelic_redis_plugin/localhost_6379"')
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_localhost_6379')
        .with_content('user="newrelic')
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_localhost_6379')
        .with_content('pid_file="/var/run/newrelic_redis_plugin/localhost_6379.pid"')
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_localhost_6379')
        .with_content('name="newrelic_localhost_6379"')
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_localhost_6379')
        .with_content('log_file="/var/log/newrelic_redis_plugin/localhost_6379.log"')
    end
  end

  context 'When the Newrelic license key is specified' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new do |node|
        node.set['newrelic_redis_plugin']['newrelic_license_key'] = 'abc123'
      end
      runner.converge(described_recipe)
    end
    it 'creates executable script with the correct name and settings' do
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/localhost_6379')
        .with_content("'newrelic' => {'license_key' => \"abc123\"},")
    end
  end

  context 'When the instance name is Specified' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new do |node|
        node.set['newrelic_redis_plugin']['instances'] = [
          {
            name:   'custom_name',
            url:    'redis://localhost:6380'
          }
        ]
      end
      runner.converge(described_recipe)
    end

    it 'creates executable script with the correct name and settings' do
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/custom_name')
        .with_content("pid_path = '/var/run/newrelic_redis_plugin/custom_name.pid'")
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/custom_name')
        .with_content("log_path = '/var/log/newrelic_redis_plugin/custom_name.log'")
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/custom_name')
        .with_content("runner = Dante::Runner.new('custom_name_newrelic_agent', :pid_path  => pid_path, :log_path => log_path)")
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/custom_name')
        .with_content('@redis = Redis.new(url: "redis://localhost:6380")')
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/custom_name')
        .with_content("'redis' => {'instance_name' => \"custom_name\", 'url' => \"redis://localhost:6380\"},")
    end
    it 'creates init script with the correct name and settings' do
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_custom_name')
        .with_content("\# Provides: newrelic_custom_name")
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_custom_name')
        .with_content('cmd="/opt/newrelic_redis_plugin/custom_name"')
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_custom_name')
        .with_content('user="newrelic')
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_custom_name')
        .with_content('pid_file="/var/run/newrelic_redis_plugin/custom_name.pid"')
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_custom_name')
        .with_content('name="newrelic_custom_name"')
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_custom_name')
        .with_content('log_file="/var/log/newrelic_redis_plugin/custom_name.log"')
    end
  end

  context 'When a database name is specified' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new do |node|
        node.set['newrelic_redis_plugin']['instances'] = [
          {
            name:   'custom_name_2',
            url:    'redis://localhost:6381',
            database: 'db0'
          }
        ]
      end
      runner.converge(described_recipe)
    end
    it 'creates executable script with database section' do
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/custom_name_2')
        .with_content('dbstat = info["db0"]')
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/custom_name_2')
        .with_content("'redis' => {'instance_name' => \"custom_name_2\", 'url' => \"redis://localhost:6381\", 'database' => \"db0\"},")
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
    it 'creates all executables with unique settings' do
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/custom_name_A')
        .with_content('@redis = Redis.new(url: "redis://localhost:6382")')
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/custom_name_A')
        .with_content('dbstat = info["dbA"]')
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/custom_name_B')
        .with_content('@redis = Redis.new(url: "redis://localhost:6383")')
      expect(chef_run)
        .to render_file('/opt/newrelic_redis_plugin/custom_name_B')
        .with_content('dbstat = info["dbB"]')
    end
    it 'creates all init scripts with the unique settings' do
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_custom_name_A')
        .with_content("\# Provides: newrelic_custom_name_A")
      expect(chef_run)
        .to render_file('/etc/init.d/newrelic_custom_name_B')
        .with_content("\# Provides: newrelic_custom_name_B")
    end
  end
end
# rubocop:enable Metrics/LineLength
