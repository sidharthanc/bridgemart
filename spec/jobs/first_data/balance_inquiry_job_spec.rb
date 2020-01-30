describe FirstData::BalanceInquiryJob do
  describe 'perform' do
    let(:code) { codes(:logan) }
    before do
      expect(FirstData::Request).to receive_message_chain(:new, perform: first_data_response('closed_loop/balance_inquiry_success.xml'))
      allow(code).to receive(:fields).and_return('extended_account_number' => 'FOOMAN-CHU')
    end

    it 'updates the code balance' do
      expect { subject.perform code }.to change(code, :balance_cents).to(35)
    end

    xcontext 'Usage mode: multi- and single-use' do
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

    xcontext 'create a placeholder usage record for the transaction in the response' do
      it 'has a balance discrepancy' do
        expect do
          subject.perform code
        end.to change { code.reload.usages.count }.by 1

        expect(code.status).to eq 'partially_used'

        adjustment_usage = code.usages.find_by(external_id: FirstData::Transaction::PLACEHOLDER)

        expect(adjustment_usage).to be_present
        expect(adjustment_usage.amount).to eq 4965.to_money
        expect(adjustment_usage.reason).to eq t('balance_discrepancy')
      end

      it 'does not have a balance discrepancy' do
        code.update limit_cents: 35

        expect do
          subject.perform code
        end.to change { code.reload.usages.count }.by 1

        expect(code.status).to eq 'partially_used'

        adjustment_usage = code.usages.find_by(external_id: FirstData::Transaction::PLACEHOLDER)

        expect(adjustment_usage).to be_present
        expect(adjustment_usage.amount).to eq 0.to_money
        expect(adjustment_usage.reason).to eq FirstData::Transaction::PLACEHOLDER
      end
    end
  end
end
