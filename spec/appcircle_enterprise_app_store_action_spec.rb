describe Fastlane::Actions::AppcircleEnterpriseAppStoreAction do
  describe '#run' do
    context 'when personalAPIToken and personalAccessKey are both nil' do
      it 'raises an error for missing authentication' do
        params = {
          personalAPIToken: nil,
          personalAccessKey: nil,
          appPath: 'test.ipa',
          summary: 'Test summary',
          releaseNotes: 'Test release notes',
          publishType: '1'
        }

        expect do
          Fastlane::Actions::AppcircleEnterpriseAppStoreAction.run(params)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end
    end

    context 'when both personalAPIToken and personalAccessKey are provided' do
      it 'raises an error for multiple authentication methods' do
        params = {
          personalAPIToken: 'test_token',
          personalAccessKey: 'test_key',
          appPath: 'test.ipa',
          summary: 'Test summary',
          releaseNotes: 'Test release notes',
          publishType: '1'
        }

        expect do
          Fastlane::Actions::AppcircleEnterpriseAppStoreAction.run(params)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end
    end

    context 'when appPath has invalid extension' do
      it 'raises an error for invalid file extension' do
        params = {
          personalAPIToken: 'test_token',
          personalAccessKey: nil,
          appPath: 'test.txt',
          summary: 'Test summary',
          releaseNotes: 'Test release notes',
          publishType: '1'
        }

        expect do
          Fastlane::Actions::AppcircleEnterpriseAppStoreAction.run(params)
        end.to raise_error(RuntimeError, /Invalid file extension/)
      end
    end

    context 'when publishType is invalid' do
      it 'raises an error for invalid publish type' do
        params = {
          personalAPIToken: 'test_token',
          personalAccessKey: nil,
          appPath: 'test.ipa',
          summary: 'Test summary',
          releaseNotes: 'Test release notes',
          publishType: '5'
        }

        expect do
          Fastlane::Actions::AppcircleEnterpriseAppStoreAction.run(params)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end
    end
  end

  describe '.description' do
    it 'returns a description' do
      expect(Fastlane::Actions::AppcircleEnterpriseAppStoreAction.description).to eq("Efficiently publish your apps to Appcircle Enterprise Store")
    end
  end

  describe '.authors' do
    it 'returns the authors' do
      expect(Fastlane::Actions::AppcircleEnterpriseAppStoreAction.authors).to eq(["Guven Karanfil"])
    end
  end

  describe '.is_supported?' do
    it 'returns true for all platforms' do
      expect(Fastlane::Actions::AppcircleEnterpriseAppStoreAction.is_supported?(:ios)).to be true
      expect(Fastlane::Actions::AppcircleEnterpriseAppStoreAction.is_supported?(:android)).to be true
    end
  end

  describe '.available_options' do
    it 'returns available options' do
      options = Fastlane::Actions::AppcircleEnterpriseAppStoreAction.available_options
      expect(options).not_to be_empty
      expect(options.map(&:key)).to include(:personalAPIToken, :personalAccessKey, :appPath, :summary, :releaseNotes, :publishType)
    end
  end
end
