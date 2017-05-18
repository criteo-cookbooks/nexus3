# coding: utf-8

require_relative '../../spec_helper'

describe 'Nexus3::Api' do
  let(:api_client) do
    Nexus3::Api.new('http://localhost/sample/api/', 'admin', 'admin123')
  end

  let(:repo_list) do
    [
      {
        'name' => 'foo',
        'content' => 'repository.createMavenHosted(\'foo\')',
        'type' => 'groovy'
      },
      {
        'name' => 'anonymous',
        'content' => 'security.setAnonymousAccess(Boolean.valueOf(args))',
        'type' => 'groovy'
      }
    ]
  end

  let(:repo_list2) do
    repo_list <<
      {
        'name' => 'maven-test',
        'content' => 'repository.createMavenHosted(\'maven-test\')',
        'type' => 'groovy'
      }
  end

  before(:each) do
    WebMock.disable_net_connect!
  end

  after(:each) do
    WebMock.allow_net_connect!
  end
end
