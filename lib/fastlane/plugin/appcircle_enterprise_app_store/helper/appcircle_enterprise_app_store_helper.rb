require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class AppcircleEnterpriseAppStoreHelper
      # class methods that you define here become available in your action
      # as `Helper::AppcircleEnterpriseAppStoreHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the appcircle_enterprise_app_store plugin helper!")
      end
    end
  end
end
