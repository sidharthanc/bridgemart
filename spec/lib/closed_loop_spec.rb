describe ClosedLoop do
  describe 'fields' do
    describe 'source_code' do
      describe 'lambda'
      it 'returns 31 if not using encryption' do
        stub_const('ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION', false)
        expect(described_class::FIELDS[:source_code][:lambda].call).to eq '31'
      end
      it 'returns 30 if using encryption' do
        stub_const('ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION', true)
        expect(described_class::FIELDS[:source_code][:lambda].call).to eq '30'
      end
    end
  end
end
