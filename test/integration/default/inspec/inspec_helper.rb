CREDS = { user: 'admin', pass: 'admin123' }.freeze
SCRIPT_API = 'http://localhost:8081/service/rest/v1/script'.freeze
JSON_HEADERS = { 'Content-Type' => 'application/json' }.freeze
TEXT_HEADERS = { 'Content-Type' => 'text/plain' }.freeze

def nexus3_script_get(endpoint)
  http("#{SCRIPT_API}/#{endpoint}", auth: CREDS)
end

def nexus3_script_post(endpoint, data = nil, headers = TEXT_HEADERS)
  http("#{SCRIPT_API}/#{endpoint}", auth: CREDS, method: 'POST', headers: headers, data: data)
end
