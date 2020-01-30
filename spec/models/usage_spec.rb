describe Usage, type: :model do
  it { is_expected.to belong_to(:code) }

  describe '#to_csv' do
    it 'returns a csv for a collection of code usages' do
      csv = described_class.all.to_csv

      described_class.all.each do |usage|
        record = [
          usage.code_id,
          usage.order,
          usage.amount,
          usage.created_at,
          usage.updated_at,
          usage.activity,
          usage.reason,
          usage.result,
          usage.notes,
          usage.used_at,
          usage.external_id,
          usage.amount_currency,
          usage.visit_number,
          usage.store_city,
          usage.store_state,
          usage.total_usage,
          usage.total_usage_currency,
          usage.total_per_visit,
          usage.total_per_visit_currency,
          usage.retail_price,
          usage.retail_price_currency,
          usage.store_number,
          usage.department_category,
          usage.upc_number,
          usage.upc_description,
          usage.company_type,
          usage.transaction_detail_identifier
        ].join(',')
        expect(csv).to include record
        expect(csv).not_to match /translation missing/
      end
    end
  end

  context '#code_identifier' do
    let(:usage) { usages(:matt) }
    let(:legacy_usage) { Usage.create!(code: codes(:angelita), amount_cents: 123_499, used_at: '01/08/2018') }

    it 'has a legacy identifier' do
      expect(legacy_usage.code_identifier).to eq legacy_usage.code.legacy_identifier
      expect(legacy_usage.code_identifier).not_to eq legacy_usage.code.id
    end

    it 'does not have a legacy identifier' do
      expect(usage.code_identifier).to eq usage.code.id
      expect(usage.code_identifier).not_to eq usage.code.legacy_identifier
    end
  end

  context '#update caches' do
    let(:usage) { usages(:matt) }
    let(:organization) { usage.code.organization }
    it 'should have nil usage total' do
      expect(organization.usage_total_cached_cents).to be nil
    end

    it 'should update cached values' do
      expect(organization.usage_total_cached_cents).to be nil
      Usage.create!(code: usage.code, amount_cents: 123_499, used_at: '01/08/2018')
      expect(organization.usage_total_cached).to eq organization.usages.sum(&:amount)
    end
  end
end
