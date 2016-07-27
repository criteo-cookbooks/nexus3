require 'serverspec_helper'

describe 'nexus::default' do
  describe file('/opt/nexus') do
    it { should be_directory }
    it { should be_owned_by 'nexus' }
  end

  describe file('/opt/nexus/nexus3') do
    it { should be_symlink }
    it { should be_owned_by 'nexus' }
  end

  describe file('/opt/repository/data') do
    it { should be_directory }
    it { should be_owned_by 'nexus' }
  end

  describe service('nexus') do
    it { should be_enabled } unless os[:family] == 'debian'
    it { should be_running }
  end
end
