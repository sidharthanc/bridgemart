describe Walmart::BatchTransactionHistoryJob do
  let(:usage_import) do
    UsageImport.create! do |usage_import|
      File.open file_fixture('walmart-usage.xlsx') do |file|
        usage_import.file.attach(io: file, filename: 'usage.xlsx')
      end
    end
  end
  let(:reload_import) do
    UsageImport.create! do |usage_import|
      File.open file_fixture('walmart-reload.xlsx') do |file|
        usage_import.file.attach(io: file, filename: 'reload.xlsx')
      end
    end
  end

  describe '#perform' do
    context 'with existing codes, usage import' do
      before do
        Code.create! external_id: '6134097516299869', member: members(:kaleb), plan_product_category: plan_product_categories(:exam), limit: 100
        Code.create! external_id: '6157327011854546', member: members(:kaleb), plan_product_category: plan_product_categories(:fashion), limit: 200
      end

      it 'should create non zero amount usages and cull out duplicates' do
        expect do
          expect do
            subject.perform usage_import
          end.to change { Usage.count }.by(3)
        end.to enqueue_job(FirstData::BatchBalanceInquiryJob).with(Code.last(2).pluck(:id))

        expect(UsageImport.last.problems.join).to match /Duplicate usage found at row \d*/
      end
    end

    context 'with existing codes, reload import' do
      before do
        Code.create! external_id: '6134097516299869', member: members(:kaleb), plan_product_category: plan_product_categories(:exam), limit: 100
        Code.create! external_id: '6157327011854546', member: members(:kaleb), plan_product_category: plan_product_categories(:fashion), limit: 200
      end

      it 'should create usages and cull out duplicates' do
        expect { subject.perform reload_import }.to change { Usage.count }.by(3)
        expect(UsageImport.last.problems.join).to match /Duplicate usage found at row \d*/
      end

      it 'should enqueue balance inquiry jobs' do
        expect { subject.perform reload_import }.to enqueue_job(FirstData::BatchBalanceInquiryJob).with(Code.last(2).pluck(:id))
      end

      it 'should adjust the amounts' do
        expect { subject.perform reload_import }.to change { Usage.sum(&:amount) }.by(-412.36.to_money)
      end
    end

    context 'with missing codes' do
      it 'should save the import problems' do
        Code.create! external_id: '6134097516299869', member: members(:kaleb), plan_product_category: plan_product_categories(:exam), limit: 100

        expect do
          expect do
            subject.perform usage_import
          end.to change { usage_import.problems&.count }.from(nil).to(2)
        end.to enqueue_job(FirstData::BatchBalanceInquiryJob).with([Code.last.id])

        expect(UsageImport.last.problems.join).to match /Code ID \d* not found at row \d*/
      end
    end
  end
end
