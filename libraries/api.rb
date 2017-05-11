module Nexus3
  class Api
    require 'json'

    def initialize(base_url, user, password)
      @http_client = HTTPClient.new(base_url: base_url).tap do |client|
        # Authentication
        client.set_auth(nil, user, password)
        client.force_basic_auth
        # Debugging
        client.debug_dev = STDOUT if ::Chef::Log.debug? || (ENV['HTTPCLIENT_LOG'] == 'stdout')
      end
    end

    attr_reader :http_client

    def request(method, path, data = nil)
      response = http_client.request(method, path, data)

      raise "HTTP_STATUS=#{response.status_code}#{response.body}" unless response.ok?

      @response = response.body
    rescue => e
      error_message = " with following error\n#{e.response.body}" if e.respond_to? 'response'
      raise "Nexus API: '#{e}' #{error_message}"
    end

    # Query Nexus3 API for list of repos, returns struct (parsed JSON)
    def list_repositories
      JSON.parse(request(:get, @url))
    end
  end
end
