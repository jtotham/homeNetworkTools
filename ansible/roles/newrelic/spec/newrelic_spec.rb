require 'spec_helper'

describe 'newrelic agent' do
  describe package('newrelic-sysmond') do
    it { should be_installed }
  end
end
