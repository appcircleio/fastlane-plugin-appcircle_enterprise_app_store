require 'net/http'
require 'uri'
require 'json'
require 'rest-client'

BASE_URL = "https://api.appcircle.io"

module UploadService
  def self.put_with_retry(url, body, headers, max_retries: 5)
    attempt = 0
    delay = 1.0

    begin
      RestClient.put(url, body, headers)
    rescue => e
      status = e.respond_to?(:http_code) ? e.http_code : nil
      retryable = status == 503 ||
                  e.is_a?(RestClient::ServerBrokeConnection) ||
                  e.is_a?(Errno::ECONNRESET) ||
                  (defined?(RestClient::Exceptions::OpenTimeout) && e.is_a?(RestClient::Exceptions::OpenTimeout)) ||
                  (defined?(RestClient::Exceptions::ReadTimeout) && e.is_a?(RestClient::Exceptions::ReadTimeout))

      raise e if !retryable || attempt >= max_retries

      attempt += 1
      sleep(delay + rand(0.3)) # backoff + jitter (0-300ms)
      delay *= 2
      retry
    end
  end

  
  def self.upload_artifact(token:, app:, api_endpoint: BASE_URL)
    file_path = app
    file_name = File.basename(file_path)
    file_size = File.size(file_path)
    auth_header = { Authorization: "Bearer #{token}", accept: 'application/json' }

    begin
      info_uri = URI("#{api_endpoint}/store/v1/profiles/app-versions")
      info_uri.query = URI.encode_www_form({ action: 'uploadInformation', fileName: file_name, fileSize: file_size })
      upload_info = JSON.parse(RestClient.get(info_uri.to_s, auth_header).body)
      file_id = upload_info['fileId']
      upload_url = upload_info['uploadUrl']
      configuration = upload_info['configuration']
      http_method = (configuration && configuration['httpMethod']) ? configuration['httpMethod'].to_s.upcase : 'PUT'

      if http_method == 'POST'
        sign_parameters = configuration['signParameters'] || {}
        payload = {}
        sign_parameters.each { |key, value| payload[key] = value }
        payload['file'] = File.new(file_path, 'rb') # the 'file' field MUST be last
        RestClient.post(upload_url, payload)
      else
        put_with_retry(upload_url, File.binread(file_path), { content_type: 'application/octet-stream' })
      end

      commit_uri = URI("#{api_endpoint}/store/v1/profiles/app-versions")
      commit_uri.query = URI.encode_www_form({ action: 'commitFileUpload', createNewProfile: true })

      commit_payload = { fileId: file_id, fileName: file_name }.to_json
      commit_headers = { Authorization: "Bearer #{token}", content_type: :json, accept: 'application/json' }
      JSON.parse(RestClient.post(commit_uri.to_s, commit_payload, commit_headers).body)
    rescue RestClient::ExceptionWithResponse => e
      raise e
    rescue StandardError => e
      raise e
    end
  end

  def self.getAppVersions(auth_token:, entProfileId:, api_endpoint: BASE_URL)
    url = "#{api_endpoint}/store/v2/profiles/#{entProfileId}/app-versions"

    # Set up the headers with authentication
    headers = {
      Authorization: "Bearer #{auth_token}",
      accept: 'application/json'
    }

    begin
      response = RestClient.get(url, headers)
      JSON.parse(response.body)
    rescue RestClient::ExceptionWithResponse => e
      raise e
    rescue StandardError => e
      raise e
    end
  end

  def self.getVersionId(versionList:)
    if versionList.kind_of?(Array) && !versionList.empty?
      return versionList[0]["id"]
    else
      return nil
    end
  rescue StandardError => e
    puts("An error occurred while getting app versions: #{e.message}")
    raise e
  end

  def self.publishVersion(options)
    endpoint = "store/v2/profiles/#{options[:ent_profile_id]}/app-versions/#{options[:ent_version_id]}?action=publish"
    url = "#{options[:api_endpoint] || BASE_URL}/#{endpoint}"

    payload = {
      summary: options[:summary],
      releaseNotes: options[:release_notes],
      publishType: options[:publish_type]
    }

    headers = {
      'Content-Type': 'application/json',
      Authorization: "Bearer #{options[:auth_token]}"
    }

    response = RestClient.patch(url, payload.to_json, headers)
    JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse => e
    raise e
  end

  def self.getEntProfiles(authToken:, api_endpoint: BASE_URL)
    url = "#{api_endpoint}/store/v2/profiles"
    headers = {
      Authorization: "Bearer #{authToken}",
      accept: 'application/json'
    }

    begin
      response = RestClient.get(url, headers)
      JSON.parse(response.body)
    rescue RestClient::ExceptionWithResponse => e
      raise e
    rescue StandardError => e
      raise e
    end
  end

  def self.getProfileId(authToken:, api_endpoint: BASE_URL)
    profiles = self.getEntProfiles(authToken: authToken, api_endpoint: api_endpoint)
    return nil unless profiles.is_a?(Array) && !profiles.empty?

    sortedProfiles = profiles.sort_by do |profile|
      date = profile["lastBinaryReceivedDate"]
      date ? DateTime.parse(date) : DateTime.new(0)
    end.reverse

    sortedProfiles[0] && sortedProfiles[0]['id']
  end
end
