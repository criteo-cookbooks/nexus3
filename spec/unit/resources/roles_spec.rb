require 'spec_helper'

describe 'nexus3_test::roles' do
  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: CENTOS_VERSION,
                               file_cache_path: CACHE).converge(described_recipe)
    end

    it 'creates a role' do
      expect(chef_run).to create_nexus3_role('foo')
    end

    it 'deletes a role' do
      expect(chef_run).to create_nexus3_role('bar')
      expect(chef_run).to delete_nexus3_role('bar')
    end

    it 'updates a role' do
      expect(chef_run).to create_nexus3_role('baz')
      expect(chef_run).to create_nexus3_role('baz again')
        .with(privileges: ['nx-blobstores-read', 'nx-ldap-read'])
    end
  end
end
