lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/appcircle_enterprise_app_store/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-appcircle_enterprise_app_store'
  spec.version       = Fastlane::AppcircleEnterpriseAppStore::VERSION
  spec.author        = 'appcircleio'
  spec.email         = 'cloud@appcircle.io'

  spec.summary       = 'Efficiently publish your apps to Appcircle Enterprise Store'
  spec.homepage      = "https://github.com/appcircleio/fastlane-plugin-appcircle_enterprise_app_store"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'false'
  spec.required_ruby_version = '>= 2.6'

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'
  spec.add_dependency "rest-client"
end
