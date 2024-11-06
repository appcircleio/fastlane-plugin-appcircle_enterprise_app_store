require 'fastlane/action'
require 'net/http'
require 'uri'
require 'json'

require 'fastlane/action'
require_relative '../helper/appcircle_enterprise_app_store_helper'

require_relative '../helper/auth_service'
require_relative '../helper/upload_service'

module Fastlane
  module Actions
    class AppcircleEnterpriseAppStoreAction < Action
      @@apiToken = nil

      def self.run(params)
        personalAPIToken = params[:personalAPIToken]
        appPath = params[:appPath]
        summary = params[:summary]
        releaseNotes = params[:releaseNotes]
        publishType = params[:publishType]

        valid_extensions = ['.apk', '.aab', '.ipa']

        file_extension = File.extname(appPath).downcase
        unless valid_extensions.include?(file_extension)
          raise "Invalid file extension: #{file_extension}. For Android, use .apk or .aab. For iOS, use .ipa."
        end

        if personalAPIToken.nil?
          raise UI.error("Please provide Personal API Token to authenticate connections to Appcircle services")
        elsif appPath.nil?
          raise UI.error("Please specify the path to your application file. For iOS, this can be a .ipa file path. For Android, specify the .apk or .aab file path")
        elsif summary.nil?
          raise UI.error("Please provide a summary for the application to be published. This summary will be displayed in the Appcircle Enterprise App Store")
        elsif releaseNotes.nil?
          raise UI.error("Please provide release notes for the application to be published. These notes will be displayed in the Appcircle Enterprise App Store")
        elsif publishType.nil?
          raise UI.error("Please specify the publish type for the application. This can be 0: None, 1: Beta, 2: Live. Default is 0: None. For more information, provide the number of the publish type")
        elsif publishType != "0" && publishType != "1" && publishType != "2"
          raise UI.error("Please provide a valid publish type. This can be 0: None, 1: Beta, 2: Live. Default is 0: None. For more information, provide the number of the publish type")
        end


        self.ac_login(personalAPIToken)
        self.uploadToProfile(appPath, summary, releaseNotes, publishType)
      end


      def self.ac_login(accessToken)
        begin
          user = AuthService.get_ac_token(pat: accessToken)
          UI.success("Login is successful.")
          @@apiToken = user.accessToken
        rescue => e
          UI.error("Login failed: #{e.message}")
          raise e
        end
      end


      def self.checkTaskStatus(taskId)
        uri = URI.parse("https://api.appcircle.io/task/v1/tasks/#{taskId}")
        timeout = 1
        
        response = self.send_request(uri, @@apiToken)
        if response.is_a?(Net::HTTPSuccess)
          stateValue = JSON.parse(response.body)["stateValue"]
          if stateValue == 1
            sleep(1)
            return checkTaskStatus(taskId)
          end
          if stateValue == 3
            return true
          else
            taskStatus = {
              0 => "Unknown",
              1 => "Begin",
              2 => "Canceled",
              3 => 'Completed',
            }
            raise UI.error("#{taskId} id upload request failed with status #{taskStatus[stateValue]}.")
          end
        else
          "Upload failed with response code #{response.code} and message '#{response.message}'"
          raise
        end
      end


      def self.uploadToProfile(appPath, summary, releaseNotes, publishType)
        response = UploadService.upload_artifact(token: @@apiToken, app: appPath)
        result = self.checkTaskStatus(response["taskId"])

        if result
          profileId = UploadService.getProfileId(authToken: @@apiToken)
          appVersions = UploadService.getAppVersions(auth_token: @@apiToken, entProfileId: profileId)
          appVersionId = UploadService.getVersionId(versionList: appVersions)
          if publishType != "0"
            self.publishToStore(profileId, appVersionId, summary, releaseNotes, publishType)
          end
          UI.success("#{appPath} uploaded to the Appcircle Enterprise Store successfully")
        end
      end

      def self.publishToStore(entProfileId, entVersionId, summary, releaseNote, publishType)
        begin
          options = {
            auth_token: @@apiToken,
            ent_profile_id: entProfileId,
            ent_version_id: entVersionId,
            summary: summary,
            release_notes: releaseNote,
            publish_type: publishType
          }
          response = UploadService.publishVersion(options)
        rescue => e
          UI.error("App could not publish at Enterprise App Store. #{e&.response}")
          raise e
        end
      end

      def self.send_request(uri, access_token)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        request = Net::HTTP::Get.new(uri.request_uri)
        request["Authorization"] = "Bearer #{access_token}"
        http.request(request)
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
          FastlaneCore::ConfigItem.new(key: :personalAPIToken,
                                  env_name: "AC_PERSONAL_API_TOKEN",
                               description: "Provide Personal API Token to authenticate Appcircle services",
                                  optional: false,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :appPath,
                                  env_name: "AC_APP_PATH",
                               description: "Specify the path to your application file. For iOS, this can be a .ipa file path. For Android, specify the .apk or .aab file path",
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
