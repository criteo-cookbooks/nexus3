require 'spec_helper'

describe 'nexus3::default' do
  # TODO: move this under resources/default.rb
  # TODO: stub requests and remove this.
  before do
    WebMock.allow_net_connect!
  end

  after do
    WebMock.disable_net_connect!
  end

  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: 'nexus3').converge(described_recipe)
    end

    it 'converges successfully' do
      expect { :chef_run }.to_not raise_error
    end
  end

  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2', step_into: 'nexus3') do
        ENV['SYSTEMDRIVE'] = 'C:'
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { :chef_run }.to_not raise_error
    end
  end
end
