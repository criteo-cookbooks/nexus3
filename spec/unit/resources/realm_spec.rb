require 'spec_helper'

describe 'nexus3_test::realm' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: CENTOS_VERSION,
                               file_cache_path: CACHE).converge(described_recipe)
    end

    it 'enables a realm' do
      expect(chef_run).to configure_nexus3_realm('NuGetApiKey').with(enable: true)
    end

    it 'disables a realm' do
      expect(chef_run).to configure_nexus3_realm('NpmToken').with(enable: false)
    end
  end
end
