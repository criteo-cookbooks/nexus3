require 'spec_helper'

describe 'nexus3_test::groups' do
  context 'linux' do
    let(:chef_run) do
      ::ChefSpec::SoloRunner.new(platform: 'centos', version: CENTOS_VERSION, step_into: 'nexus3_group')
                            .converge(described_recipe)
    end

    it 'creates a group' do
      expect(chef_run).to create_nexus3_repo('foo-group')
      expect(chef_run).to create_nexus3_group('foo-group')
    end

    it 'deletes a group' do
      expect(chef_run).to delete_nexus3_repo('bar-group')
      expect(chef_run).to delete_nexus3_group('bar-group')
    end
  end
end
