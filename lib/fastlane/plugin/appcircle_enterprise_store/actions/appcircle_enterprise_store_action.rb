require 'fastlane/action'
require 'net/http'
require 'uri'
require 'json'
require_relative '../helper/appcircle_enterprise_store_helper'

module Fastlane
  module Actions
    class AppcircleEnterpriseStoreAction < Action
      def self.run(params)
        accessToken = params[:accessToken]
        entProfileId = params[:entProfileId]
        appPath = params[:appPath]
        summary = params[:summary]
        releaseNotes = params[:releaseNotes]
        publishType = params[:publishType]

        self.ac_login(accessToken)
        self.uploadToProfile(entProfileId, appPath, summary, releaseNotes, publishType)
        self.get_version_list(entProfileId)
      end

      def self.ac_login(accessToken)
        ac_login = `appcircle login --pat #{accessToken}`
        if $?.success?
          UI.success("Logged in to Appcircle successfully.")
        else
          raise "Error executing command of logging to Appcircle. Please make sure you have installed Appcircle CLI and provided a valid access token. For more information, please visit https://docs.appcircle.io/appcircle-api/api-authentication#generatingmanaging-the-personal-api-tokens #{ac_login}"
        end
      end


      def self.checkTaskStatus(taskId)
        uri = URI.parse("https://api.appcircle.io/task/v1/tasks/#{taskId}")
        timeout = 1
        jwtToken = `appcircle config get AC_ACCESS_TOKEN -o json`
        apiAccessToken = JSON.parse(jwtToken)
        
        response = self.send_request(uri, apiAccessToken["AC_ACCESS_TOKEN"])
        if response.is_a?(Net::HTTPSuccess)
          stateValue = JSON.parse(response.body)["stateValue"]
          
          if stateValue == 1
            return checkTaskStatus(taskId)
          else 
            return true
          end
        else
          UI.error("Request failed with response code #{response.code} and message #{response.message}")
          raise "Request failed"
        end
        return false
      end


      def self.uploadToProfile(entProfileId, appPath, summary, releaseNotes, publishType)
        # `appcircle enterprise-app-store version upload-for-profile --entProfileId ${profileId} --app ${app}`;
        ac_upload_profile = `appcircle enterprise-app-store version upload-for-profile --entProfileId #{entProfileId} --app #{appPath} -o json`
        taskId = JSON.parse(ac_upload_profile)["taskId"]
        apiAccessTokenString = `appcircle config get AC_ACCESS_TOKEN -o json`
        apiAccessToken = JSON.parse(apiAccessTokenString)
        
        if $?.success?
          result = self.checkTaskStatus(taskId)
          if result
            appVersionId = self.get_version_list(entProfileId)
            self.publishToStore(entProfileId, appVersionId, summary, releaseNotes, publishType)
          end
        else
          raise "Error executing command of uploading the application to the Appcircle Enterprise Store. Please make sure you have provided a valid profile ID and application path.#{ac_upload_profile}"
        end
      end

      def self.publishToStore(entProfileId, entVersionId, summary, releaseNote, publishType)
        # `appcircle enterprise-app-store version publish --entProfileId ${entProfileId} --entVersionId ${entVersionId} --summary "${summary}" --releaseNotes "${releaseNote}" --publishType ${publishType}`;
        publish_command = `appcircle enterprise-app-store version publish --entProfileId #{entProfileId} --entVersionId #{entVersionId} --summary "#{summary}" --releaseNotes "#{releaseNote}" --publishType #{publishType}`
        if $?.success?
          UI.success("Published the application to the Appcircle Enterprise Store successfully\n#{publish_command}")
        else
          raise "Error executing command of publishing the application to the Appcircle Enterprise Store. Please make sure you have provided a valid profile ID, version ID, summary, release notes, and publish type. #{publish_command}"
        end
      end

      def self.send_request(uri, access_token)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        request = Net::HTTP::Get.new(uri.request_uri)
        request["Authorization"] = "Bearer #{access_token}"
        http.request(request)
      end

      def self.get_version_list(entProfileId)
        store_version_list = `appcircle enterprise-app-store version list --entProfileId #{entProfileId}  -o json`;
        appVersionId = self.getVersionId(store_version_list)
        UI.message("Uploaded App ID: #{appVersionId}")
        return appVersionId
      end
      
      def self.getVersionId(versions)
        begin
          versionList = JSON.parse(versions)
      
          if versionList.is_a?(Array) && !versionList.empty?
            return versionList[0]["id"]
          else
            return nil
          end
        rescue JSON::ParserError => e
          puts "Failed to parse JSON: #{e.message}"
          nil
        rescue => e
          puts "An error occurred: #{e.message}"
          nil
        end
      end

      def self.description
        "Efficiently publish your apps to Appcircle Enterprise Store"
      end

      def self.authors
        ["Guven Karanfil"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Appcircle Enterprise Mobile App Store is your own mobile app store for providing access to in-house apps with a customizable mobile storefront"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :accessToken,
                                  env_name: "AC_ACCESS_TOKEN",
                               description: "Provide the Appcircle access token to authenticate connections to Appcircle services. This token allows your Azure DevOps pipeline to interact with Appcircle for distributing applications",
                                  optional: false,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :entProfileId,
                                  env_name: "AC_ENT_PROFILE_ID",
                               description: "Provide the Appcircle Enterprise App Store Mobile Profile ID to specify the profile to be used for the publishment. This ID can be found in the Enterprise App Store Mobile module dashboard",
                                  optional: false,
                                      type: String),                                      

          FastlaneCore::ConfigItem.new(key: :appPath,
                                  env_name: "AC_APP_PATH",
                               description: "Specify the path to your application file. For iOS, this can be a .ipa or .xcarchive file path. For Android, specify the .apk or .appbundle file path",
                                  optional: false,
                                      type: String),                            

          FastlaneCore::ConfigItem.new(key: :summary,
                                  env_name: "AC_SUMMARY",
                               description: "Provide a summary for the application to be published. This summary will be displayed in the Appcircle Enterprise App Store",
                                  optional: false,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :releaseNotes,
                                  env_name: "AC_RELEASE_NOTES",
                               description: "Provide release notes for the application to be published. These notes will be displayed in the Appcircle Enterprise App Store",
                                  optional: false,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :publishType,
                                  env_name: "AC_PUBLISH_TYPE",
                               description: "Specify the publish type for the application. This can be 0: None, 1: Beta, 2: Live. Default is 0: None. For more information, provide the number of the publish type",
                                  optional: false,
                                      type: String),
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
