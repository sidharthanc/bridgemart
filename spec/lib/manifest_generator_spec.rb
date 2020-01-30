describe ManifestGenerator do
  subject { described_class.new('staging') }
  around do |example|
    ClimateControl.modify IMAGE: 'bridge-rails:deploy-image', RAILS_MASTER_KEY: 'THIS_IS_SEKRET' do
      example.run
    end
  end
  describe 'env' do
    it { expect(subject.env).to be_a Hash }
    it { expect(subject.env).to include("ACR_NAME", "RAILS_ENV") }
  end
  describe 'generate' do
    it 'populates the yaml file properly' do
      expect(subject.generate).to include 'value: "staging"'
      expect(subject.generate).to include 'image: "bridge-rails:deploy-image"'
      expect(subject.generate).to include 'value: "THIS_IS_SEKRET"' # Rails Master Key
    end
  end
end
