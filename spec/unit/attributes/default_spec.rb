require 'spec_helper'

describe 'nexus3::default' do
  context 'nexus3.desired_heap_size' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: CENTOS_VERSION, step_into: 'nexus3')
                          .converge(described_recipe)
    end

    it 'controls the Xms & Xmx JVM variables' do
      chef_run.node.default['nexus3']['desired_heap_size'] = '12G'
      expect(chef_run.node['nexus3']['vmoptions_variables']).to include('Xms12G', 'Xmx12G')
      chef_run.node.default['nexus3']['desired_heap_size'] = '8G'
      expect(chef_run.node['nexus3']['vmoptions_variables']).not_to include('Xms12G', 'Xmx12G')
      expect(chef_run.node['nexus3']['vmoptions_variables']).to include('Xms8G', 'Xmx8G')
    end
  end
end
