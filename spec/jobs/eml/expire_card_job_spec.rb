describe EML::ExpireCardJob do
  describe 'perform' do
    let(:code) { codes(:logan) }

    it 'deactivates the card' do
      expect(EML::LockCardJob).to receive(:perform_now).with(code, 'expired')
      expect(code.reload.deactivated_at).to be_nil

      subject.perform code
      code.reload

      expect(code.deactivated_at).not_to be_nil
    end
  end
end
