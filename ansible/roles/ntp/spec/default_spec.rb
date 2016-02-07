require 'spec_helper'

describe service('ntp') do
  it { should be_enabled }
  it { should be_running }
end

describe port(123) do
  it { should be_listening }
end

# wait for ntp to sync with peers

describe command('ntpq -pn') do
  retries = 0
  begin  
    its(:stdout) { should match /^\*\d/ }
  rescue
    raise if retries >= 6
    retries += 1
    sleep(10)
    retry
  end
end


