describe ClosedLoop::Transactions::AssignMerchantKey do
  subject { described_class.new(key_id: 42) }

  it { expect(subject.request.transaction).to eq :assign_merchant_working_key }
  it 'includes all the required fields' do
    expect(subject.request.included_codes).to include('12', '13', '15', '42', '63', 'EA', 'F3')
  end
  context 'in the console' do
    before do
      allow(STDOUT).to receive(:puts)
      stub_const("Rails::Console", 'defined')
    end
    it 'outputs the key used for assignment' do
      expect { described_class.new(key_id: 42) }.to output("Using merchant key 42\n").to_stdout
    end
  end
end
