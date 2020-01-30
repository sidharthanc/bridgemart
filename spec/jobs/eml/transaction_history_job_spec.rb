describe EML::TransactionHistoryJob do
  describe 'perform' do
    let(:code) { codes(:logan) }
    let(:url) { %r{cards/#{code.card_number}/transactions} }

    context 'Usage mode: multi- and single-use' do
      before do
        webmock :get, url => 'eml/GET_transactions.200.json', with: Hash[query: { skip: '0', take: '20' }]
        webmock :get, url => 'eml/GET_transactions_pg3.200.json', with: Hash[query: { skip: '20', take: '20' }]
      end

      it 'is a multi-use code and does not deactivate after the first use' do
        subject.perform code
        expect(code.reload).to be_active
      end

      it 'is a single-use code and deactivates after the first use' do
        code.plan_product_category.update usage_type: PlanProductCategory.usage_types[:single_use]
        subject.perform code
        expect(code.reload).to be_inactive
      end
    end

    it 'create usage records for each non zero amount transaction in the response' do
      webmock :get, url => 'eml/GET_transactions.200.json', with: Hash[query: { skip: '0', take: '20' }]
      webmock :get, url => 'eml/GET_transactions_pg3.200.json', with: Hash[query: { skip: '20', take: '20' }]

      manual_adjustment_usage = code.usages.find_by(amount_cents: -101)
      auth_request_usage = code.usages.find_by(amount_cents: -500)

      expect(manual_adjustment_usage).not_to be_present
      expect(auth_request_usage).not_to be_present

      expect do
        subject.perform code
      end.to change { code.reload.usages.count }.by 2

      expect(code.status).to eq 'partially_used'

      manual_adjustment_usage = code.usages.find_by(amount_cents: -101)
      auth_request_usage = code.usages.find_by(amount_cents: -500)

      expect(manual_adjustment_usage).to be_present
      expect(auth_request_usage).to be_present

      manual_adjustment_usage.tap do |usage|
        expect(usage.amount).to eq(-1.01.to_money)
        expect(usage.activity).to eq 'Manual Adjustment'
        expect(usage.reason).to eq 'Manual Adjustment'
        expect(usage.result).to eq 'Adjusted'
        expect(usage.notes).to eq 'test'
        expect(usage.used_at.to_i).to eq 1_497_389_473
        expect(usage.external_id).to eq '58569654'
      end

      auth_request_usage.tap do |usage|
        expect(usage.amount).to eq(-5.to_money)
        expect(usage.activity).to eq 'Authorization Request'
        expect(usage.reason).to eq 'Transaction currency does not match card currency'
        expect(usage.result).to eq 'Declined'
        expect(usage.notes).to be_nil
        expect(usage.used_at.to_i).to eq 1_497_387_301
        expect(usage.external_id).to eq '85624587'
      end
    end

    it 'does not duplicate transactions' do
      webmock :get, url => 'eml/GET_transactions.200.json', with: Hash[query: { skip: '0', take: '20' }]
      webmock :get, url => 'eml/GET_transactions_pg3.200.json', with: Hash[query: { skip: '20', take: '20' }]
      expect { subject.perform code }.to change { code.reload.usages.count }.by 2
      expect { subject.perform code }.to_not change(Usage, :count)
    end

    it 'loops through each page until receiving a blank result' do
      webmock :get, url => 'eml/GET_transactions.200.json', with: Hash[query: { skip: '0', take: '20' }]
      webmock :get, url => 'eml/GET_transactions_pg2.200.json', with: Hash[query: { skip: '20', take: '20' }]
      webmock :get, url => 'eml/GET_transactions_pg3.200.json', with: Hash[query: { skip: '40', take: '20' }]

      expect do
        subject.perform code
      end.to change { code.reload.usages.count }.by 3
    end

    context 'API fails' do
      it 'raises an exception' do
        webmock :get, url => 'eml/error.500.json'
        expect do
          subject.perform code
        end.to raise_error(EML::Error)
      end
    end
  end
end
