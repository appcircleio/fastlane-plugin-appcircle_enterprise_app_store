describe Fastlane::Actions::AppcircleEnterpriseStoreAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The appcircle_enterprise_store plugin is working!")

      Fastlane::Actions::AppcircleEnterpriseStoreAction.run(nil)
    end
  end
end
