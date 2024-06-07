require 'fastlane/action'
require_relative '../helper/appcircle_enterprise_store_helper'

module Fastlane
  module Actions
    class AppcircleEnterpriseStoreAction < Action
      def self.run(params)
        UI.message("The appcircle_enterprise_store plugin is working!")
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
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "APPCIRCLE_ENTERPRISE_STORE_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
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
