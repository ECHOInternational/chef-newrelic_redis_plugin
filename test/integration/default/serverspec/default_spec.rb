# frozen_string_literal: true
require 'spec_helper'

describe user('newrelic') do
  it { should exist }
  it { should belong_to_group 'newrelic' }
end

describe file('/opt/newrelic_redis_plugin/ActiveJob_redis') do
  it { should exist }
  it { should be_file }
  it { should be_readable }
  it { should contain "runner.description = 'New Relic plugin agent for Redis'" }
end

describe service('newrelic_ActiveJob_redis') do
  it { should be_enabled }
end

describe command('/etc/init.d/newrelic_ActiveJob_redis status') do
  its(:exit_status) { should eq 0 }
end

describe file('/opt/newrelic_redis_plugin/Discourse_redis') do
  it { should exist }
  it { should be_file }
  it { should be_readable }
  it { should contain "runner.description = 'New Relic plugin agent for Redis'" }
end

describe service('newrelic_Discourse_redis') do
  it { should be_enabled }
end

describe command('/etc/init.d/newrelic_Discourse_redis status') do
  its(:exit_status) { should eq 0 }
end
