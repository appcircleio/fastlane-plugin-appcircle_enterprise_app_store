require 'net/http'
require 'uri'
require 'json'
require 'rest-client'

BASE_URL = "https://api.appcircle.io"


module UploadService
  def self.upload_artifact(token:, app:)
    url = "https://api.appcircle.io/store/v2/profiles/app-versions"
    headers = {
      Authorization: "Bearer #{token}",
      content_type: :multipart
    }
    payload = {
      File: File.new(app, 'rb')
    }
  
    begin
      response = RestClient.post(url, payload, headers)
      JSON.parse(response.body) rescue response.body
    rescue RestClient::ExceptionWithResponse => e
      raise e
    rescue StandardError => e
      raise e
    end
  end

  def self.getAppVersions(auth_token:, entProfileId:)
    url = "#{BASE_URL}/store/v2/profiles/#{entProfileId}/app-versions"

    # Set up the headers with authentication
    headers = {
      Authorization: "Bearer #{auth_token}",
      accept: 'application/json'
    }

    begin
      response = RestClient.get(url, headers)
      parsed_response = JSON.parse(response.body)

      parsed_response
    rescue RestClient::ExceptionWithResponse => e
      raise e
    rescue StandardError => e
      raise e
    end
  end

  def self.getVersionId(versionList:)
    begin
      if versionList.is_a?(Array) && !versionList.empty?
        return versionList[0]["id"]
      else
        return nil
      end
    rescue => e
      puts "An error occurred while getting app versions: #{e.message}"
      raise e
    end
  end

  def self.publishVersion(options)
    endpoint = "store/v2/profiles/#{options[:ent_profile_id]}/app-versions/#{options[:ent_version_id]}?action=publish"
    url = "#{BASE_URL}/#{endpoint}"

    payload = {
      summary: options[:summary],
      releaseNotes: options[:release_notes],
      publishType: options[:publish_type]
    }

    headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer #{options[:auth_token]}"
    }

    response = RestClient.patch(url, payload.to_json, headers)
    JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse => e
    raise e
  end

  def self.getEntProfiles(authToken:)
    url = "#{BASE_URL}/store/v2/profiles?Sort=desc"
    headers = {
      Authorization: "Bearer #{authToken}",
      accept: 'application/json'
    }

    begin
      response = RestClient.get(url, headers)
      parsed_response = JSON.parse(response.body)

      parsed_response
    rescue RestClient::ExceptionWithResponse => e
      raise e
    rescue StandardError => e
      raise e
    end
  end

  def self.getProfileId(authToken:)
    profiles = self.getEntProfiles(authToken: authToken)
    sortedProfiles = profiles.sort_by { |profile| DateTime.parse(profile["lastBinaryReceivedDate"]) }.reverse

    return sortedProfiles[0]['id']
  end
end
