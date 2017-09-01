property :username, String, desired_state: false, identity: true, default: 'admin'.freeze
property :new_password, String, desired_state: false, identity: true, sensitive: true, default: 'admin123'.freeze
property :api_url, String, desired_state: false, identity: true, default: 'http://localhost:8081/service/siesta/rest/v1/script/'.freeze
property :api_user, String, desired_state: false, identity: true, default: 'admin'.freeze
property :api_password, String, desired_state: false, identity: true, sensitive: true, default: 'admin123'.freeze

# TODO: add load_current_resource, by testing the
# /service/metrics/ping API endpoint with the new_password. If
# successful, no need to change the password.

action :run do
  nexus3_api 'change_user_password' do
    script_name 'user_password'
    args username: new_resource.username,
         new_password: new_resource.new_password

    action %i(create run)
    endpoint new_resource.api_url
    username new_resource.api_user
    password new_resource.api_password

    content <<-EOS
import groovy.json.JsonSlurper

def params = new JsonSlurper().parseText(args)

// TODO: catch UserNotFoundException
security.securitySystem.changePassword(params.username, params.new_password)
    EOS
  end
end
