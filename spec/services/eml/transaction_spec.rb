describe EML::Transaction do
  it 'parses EML JSON' do
    transaction = EML::Transaction.parse(
      'system_transaction_id' => '123',
      'amount' => '1.23',
      'timestamp' => 'Date(0)',
      'activity' => 'Activity test',
      'reason' => 'Reason test',
      'result' => 'Result test',
      'notes' => 'Notes test'
    )

    expect(transaction.id).to eq '123'
    expect(transaction.amount).to eq(1.23.to_money)
    expect(transaction.timestamp).to eq Time.utc(1970, 1, 1, 0, 0, 0)
    expect(transaction.activity).to eq 'Activity test'
    expect(transaction.reason).to eq 'Reason test'
    expect(transaction.result).to eq 'Result test'
    expect(transaction.notes).to eq 'Notes test'
  end
end
