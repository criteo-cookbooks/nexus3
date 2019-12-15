require 'spec_helper'

describe 'nexus3_resources_test::default' do
  NON_TESTED_RESOURCES = %w[service_systemd service_windows default service_sysvinit].freeze
  cached(:chef_run) do
    ::ChefSpec::SoloRunner.new(platform: 'centos', version: CENTOS_VERSION).converge(described_recipe)
  end

  it 'converges successfully' do
    chef_run
  end

  ::Dir[::File.join(__dir__, '..', '..', 'resources', '*.rb')].each do |resource_file|
    resource_name = ::File.basename(resource_file, '.rb')
    it "validates nexus3_#{resource_name}" do
      pending 'not tested on purpose' if NON_TESTED_RESOURCES.include? resource_name
      expect(chef_run.node['nexus3_resources_test'].keys).to include(resource_name)
    end
  end
end
