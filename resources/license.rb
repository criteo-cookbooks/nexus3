property :fingerprint, String, default: lazy { node['nexus3']['license_fingerprint'] }
property :license, String, sensitive: true, default: lazy { node['nexus3']['license'] }
property :api_client, ::Nexus3::Api, identity: true, desired_state: false, default: lazy { ::Nexus3::Api.default(node) }

load_current_value do |_desired|
  begin
    config = api_client.request(:get, 'system/license')
    current_value_does_not_exist! if config.nil?
    fingerprint JSON.parse(config)['fingerprint']
  # Nexus returns a 402 Payment Required when there is no license installed, we get an ApiError
  rescue ::LoadError, ::Nexus3::ApiError => e
    ::Chef::Log.warn "A '#{e.class}' occured: #{e.message}"
    current_value_does_not_exist!
  end
end

action :update do
  converge_if_changed :fingerprint do
    converge_by('Uploading license') do
      new_resource.api_client.request(
        :post, 'system/license', data: ::Base64.decode64(new_resource.license), content_type: 'application/octet-stream'
      )
    end
  end
end

action :delete do
  unless current_resource.nil?
    converge_by('Unregistering license') do
      new_resource.api_client.request(:delete, 'system/license')
    end
  end
end

action_class do
  def whyrun_supported?
    true
  end
end
