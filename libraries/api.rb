module Nexus3
  class ApiError < RuntimeError
  end

  # Interact with the Nexus3 API
  class Api
    def self.default(node)
      new(node['nexus3']['api']['endpoint'],
          node['nexus3']['api']['username'],
          node['nexus3']['api']['password']).freeze
    end

    def self.local(port, user, password)
      new(endpoint(port), user, password).freeze
    end

    def self.endpoint(port)
      "http://localhost:#{port}/service/rest/v1/script/"
    end

    def initialize(base_url, user, password)
      require 'json'

      @endpoint = base_url
      @password = password
      @user = user
    end

    def to_s
      "#{@user}@#{@endpoint}"
    end

    # Custom inspect without sensitive data
    def inspect
      variables = instance_variables.reject { |v| v == :@password }.map { |v| " #{v}=#{instance_variable_get(v)}" }

      ::Kernel.instance_method(:to_s).bind(self).call.sub('>', "#{variables.join(',')}>")
    end

    attr_reader :endpoint

    def http_client
      require 'httpclient'
      ::HTTPClient.new(base_url: @endpoint).tap do |client|
        # Authentication
        client.set_auth(@endpoint, @user, @password)
        client.force_basic_auth = true
        # Debugging
        client.debug_dev = STDOUT if ::Chef::Log.debug? || (ENV['HTTPCLIENT_LOG'] == 'stdout')
      end
    end

    def request(method, path, content_type = 'application/json', data = nil)
      data = case data
             when Hash, Array
               JSON.generate(data)
             else
               data
             end
      res = http_client.request(method, path, nil, data, 'Content-Type' => content_type)

      res.body
    rescue StandardError => e
      error_message = " with following error\n#{e.response.body}" if e.respond_to? 'response'
      raise "Nexus API: '#{e}' #{error_message}"
    ensure
      raise ApiError, "HTTP_STATUS=#{res.status_code} #{res.body}" unless res.nil? || res.ok?
    end

    # Runs a specific script with parameters
    def run_script(scriptname, params)
      body = request(:post, "#{scriptname}/run", 'text/plain', params)
      JSON.parse(body)['result']
    end
  end
end
