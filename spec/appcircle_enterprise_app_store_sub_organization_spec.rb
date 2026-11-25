describe Fastlane::Actions::AppcircleEnterpriseAppStoreAction do
  let(:action) { described_class }

  before do
    action.class_variable_set(:@@apiToken, 'root-token')
    action.class_variable_set(:@@authEndpoint, 'https://auth.example.test')
    action.class_variable_set(:@@apiEndpoint, 'https://api.example.test')
  end

  describe '.ac_switch_sub_organization' do
    it 'keeps the root token when no name is given' do
      expect(AuthService).not_to receive(:switch_to_sub_organization)

      [nil, '', '   '].each { |name| action.ac_switch_sub_organization(name, 'my-pat', nil) }

      expect(action.class_variable_get(:@@apiToken)).to eq('root-token')
    end

    it 'switches to the sub-organization token with the PAT' do
      expect(AuthService).to receive(:switch_to_sub_organization).with(
        root_token: 'root-token', name: 'PlugInTest', pat: 'my-pat',
        auth_endpoint: 'https://auth.example.test', api_endpoint: 'https://api.example.test'
      ).and_return('sub-token')

      action.ac_switch_sub_organization(' PlugInTest ', 'my-pat', nil)

      expect(action.class_variable_get(:@@apiToken)).to eq('sub-token')
    end

    it 'switches to the sub-organization token with the personal access key' do
      expect(AuthService).to receive(:switch_to_sub_organization).with(
        root_token: 'root-token', name: 'PlugInTest', pat: 'my-pak',
        auth_endpoint: 'https://auth.example.test', api_endpoint: 'https://api.example.test'
      ).and_return('sub-token')

      action.ac_switch_sub_organization('PlugInTest', nil, 'my-pak')

      expect(action.class_variable_get(:@@apiToken)).to eq('sub-token')
    end

    it 'fails the lane and keeps no root fallback when the switch fails' do
      message = "Sub-organization 'Missing' could not be found or is not accessible with this token."
      allow(AuthService).to receive(:switch_to_sub_organization).and_raise(RuntimeError, message)

      expect do
        action.ac_switch_sub_organization('Missing', 'my-pat', nil)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, message)
    end
  end

  describe '.available_options' do
    it 'offers an optional subOrganizationName option' do
      option = action.available_options.find { |item| item.key == :subOrganizationName }

      expect(option).not_to be_nil
      expect(option.env_name).to eq('AC_SUB_ORGANIZATION_NAME')
      expect(option.optional).to be(true)
    end
  end

  describe '.run' do
    it 'switches to the sub-organization after login and before the upload' do
      params = {
        personalAPIToken: 'my-pat',
        personalAccessKey: nil,
        subOrganizationName: 'PlugInTest',
        appPath: 'test.ipa',
        summary: 'Test summary',
        releaseNotes: 'Test release notes',
        publishType: '0',
        authEndpoint: 'https://auth.example.test',
        apiEndpoint: 'https://api.example.test'
      }
      expect(action).to receive(:ac_login_with_pat).with('my-pat').ordered
      expect(action).to receive(:ac_switch_sub_organization).with('PlugInTest', 'my-pat', nil).ordered
      expect(action).to receive(:uploadToProfile).ordered

      action.run(params)
    end

    it 'switches with the personal access key after the key login' do
      params = {
        personalAPIToken: nil,
        personalAccessKey: 'my-pak',
        subOrganizationName: 'PlugInTest',
        appPath: 'test.ipa',
        summary: 'Test summary',
        releaseNotes: 'Test release notes',
        publishType: '0',
        authEndpoint: 'https://auth.example.test',
        apiEndpoint: 'https://api.example.test'
      }
      expect(action).to receive(:ac_login_with_pak).with('my-pak').ordered
      expect(action).to receive(:ac_switch_sub_organization).with('PlugInTest', nil, 'my-pak').ordered
      expect(action).to receive(:uploadToProfile).ordered

      action.run(params)
    end

    it 'does not upload when the sub-organization switch fails' do
      params = {
        personalAPIToken: 'my-pat',
        personalAccessKey: nil,
        subOrganizationName: 'Missing',
        appPath: 'test.ipa',
        summary: 'Test summary',
        releaseNotes: 'Test release notes',
        publishType: '0',
        authEndpoint: 'https://auth.example.test',
        apiEndpoint: 'https://api.example.test'
      }
      allow(action).to receive(:ac_login_with_pat)
      allow(AuthService).to receive(:switch_to_sub_organization).and_raise(RuntimeError, 'not found')
      expect(action).not_to receive(:uploadToProfile)

      expect { action.run(params) }.to raise_error(FastlaneCore::Interface::FastlaneError, 'not found')
    end

    it 'stops before the login when only one endpoint is self-hosted' do
      params = {
        personalAPIToken: 'my-pat',
        personalAccessKey: nil,
        appPath: 'test.ipa',
        summary: 'Test summary',
        releaseNotes: 'Test release notes',
        publishType: '0',
        authEndpoint: 'https://auth.example.test',
        apiEndpoint: 'https://api.appcircle.io'
      }
      expect(action).not_to receive(:ac_login_with_pat)

      expect { action.run(params) }.to raise_error(FastlaneCore::Interface::FastlaneError, 'Set both authEndpoint and apiEndpoint for a self-hosted Appcircle server, or leave both empty for the Appcircle cloud.')
    end

    it 'uses the cloud endpoints when the endpoint options are empty' do
      params = {
        personalAPIToken: 'my-pat',
        personalAccessKey: nil,
        appPath: 'test.ipa',
        summary: 'Test summary',
        releaseNotes: 'Test release notes',
        publishType: '0',
        authEndpoint: '',
        apiEndpoint: ' '
      }
      allow(action).to receive(:ac_login_with_pat)
      allow(action).to receive(:uploadToProfile)

      action.run(params)

      expect(action.class_variable_get(:@@authEndpoint)).to eq('https://auth.appcircle.io')
      expect(action.class_variable_get(:@@apiEndpoint)).to eq('https://api.appcircle.io')
    end
  end
end
