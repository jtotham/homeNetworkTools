require 'spec_helper'

describe 'sudo should be passwordless' do
  describe command('sudo -n true') do
    its(:exit_status) { should eq 0 }
  end
end

describe 'check ssh configuration' do
  describe command('/usr/bin/test $(grep -c ssh-rsa /home/jon/.ssh/authorized_keys) -gt 10') do
    its(:exit_status) { should eq 0 }
  end

  describe file('/home/jon/.ssh') do
    it { should be_directory }
    it { should be_owned_by 'jon' }
    it { should be_grouped_into 'jon' }
    it { should be_mode 700 }
  end

end


describe 'DNS' do
  describe host('wirehive.net') do
    it { should be_resolvable.by('dns') }
  end

  describe host('localhost') do
    it { should be_resolvable.by('hosts') }
  end
end

describe 'Networking' do
  describe host('wirehive.net') do
    it { should be_reachable }
  end
  
  describe host('localhost') do
    it { should be_reachable }
    it { should be_reachable.with( :port => 22 ) }
  end
end

describe 'fail2ban should be installed and running' do
  describe package('fail2ban') do
    it { should be_installed }
  end

  describe process("fail2ban-server") do
    it { should be_running }
  end
end

describe 'glances' do
  describe package('glances') do
    it { should be_installed }
  end
  
  describe process("glances") do
    it { should be_running }
    its(:args) { should match "-B 127.0.0.1" }
  end
end

describe interface('eth0') do
  it { should exist }
  it { should be_up }
end

describe default_gateway do
  its(:interface) { should eq 'eth0' }
end

describe 'check hostname set up correctly' do
  describe file('/etc/hosts') do
    its(:content) { should match '^127\.0\.\d\.\d\s+.*jonsbox.net' }
    its(:content) { should match '^(?!(^127\.0\.0\.1)|(^192\.168)|(^10\.)|(^172\.1[6-9])|(^172\.2[0-9])|(^172\.3[0-1]))\s+.+jonsbox.net' }
  end

  describe file('/etc/hostname') do
    its(:content) { should match /[a-z]/ }
  end
  
  describe command('hostname --fqdn') do
    its(:exit_status) { should eq 0 }
  end
end

describe process("vmtoolsd") do
  it { should be_running }
end

describe 'atop' do
  describe process("atop") do
    it { should be_running }
  end

  describe file('/etc/default/atop') do
    its(:content) { should match /INTERVAL=60/ }
  end

  describe process("atop") do
    its(:args) { should match " 60$" }
  end
end

describe 'snmpd' do
  describe process("snmpd") do
    it { should be_running }
  end

  describe port(161) do
    it { should be_listening.with('udp') }
  end
end

describe user('jon') do
  it { should exist }
  it { should belong_to_group 'jon' }
  it { should have_home_directory '/home/jon' }
  it { should have_login_shell '/bin/zsh' }
end

describe 'jons password should be encrypted' do
  describe file('/etc/shadow') do
    its(:content) { should match '^jon:\$6\$' }
  end
end

describe file("/etc/timezone") do
  its(:content) { should match "Europe/London"}
end

describe file('/etc/ssh/sshd_config') do
  its(:content) { should match /PermitRootLogin no/ }
end

describe file('/etc/cron.d/oomProtect') do
  its(:content) { should match "/opt/wirehive/oomProtection.sh" }
end

describe file('/etc/default/grub') do
  its(:content) { should match "1024x768" }
end

describe port(25) do
  it { should be_listening.with('tcp') }
end

