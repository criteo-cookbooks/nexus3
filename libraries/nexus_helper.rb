require 'timeout'
require 'net/http'

module Nexus3
  # Helper library for testing Nexus3 responses
  module Helper
    # Apply some logic on repo attributes hash
    def self.coerce_repo_attributes(value)
      value = value.dup
      # Ensure cleanup policies are sorted if any, to ensure coherent comparison
      if value.dig('cleanup', 'policyName').is_a?(::Array)
        value['cleanup'] = value['cleanup'].dup
        value['cleanup']['policyName'] = value['cleanup']['policyName'].sort
      end
      value
    end

    # Raise an error in case Nexus takes a really long time to start.
    class Nexus3NotReady < StandardError
      def initialize(endpoint, timeout)
        super <<~ERROR
          The Nexus server at #{endpoint} did not become ready within #{timeout}
          seconds. On large Nexus instances (or on smaller hardware), you may need
          to increase the timeout to #{timeout * 4} seconds. Alternatively, Nexus
          may have failed to start.
        ERROR
      end
    end

    def wait_until_ready!(endpoint, timeout = 15 * 60)
      uri = ::Kernel.URI(endpoint)
      Timeout.timeout(timeout, Timeout::Error) do
        begin
          response = ::Net::HTTP.get_response(uri)
          response.error! if response.code.start_with?('5')
        rescue SocketError,
               Errno::ECONNREFUSED,
               Errno::ECONNRESET,
               Errno::ENETUNREACH,
               Errno::EADDRNOTAVAIL,
               Errno::EHOSTUNREACH,
               Net::HTTPError => e

          Chef::Log.debug("Nexus3 is not accepting requests - #{e.message}")
          sleep 1
          retry
        end
      end
    rescue Timeout::Error
      raise Nexus3NotReady.new(endpoint, timeout)
    end
  end
end
