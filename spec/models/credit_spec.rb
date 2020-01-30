describe Credit, type: :model do
  it { is_expected.to belong_to(:organization) }

  context 'Credit Pool' do
    let(:organization) { organizations(:metova) }
    let(:sum_range) { 100..103 }
    let(:sum) { (100..103).sum - 100 }
    let(:sum_cents) { sum.to_money }

    it 'shows zero for no credit' do
      expect(organization.credit_total).to be_zero
    end

    it 'shows credit totals' do
      sum_range.each do |amount|
        organization.credit_pool(amount: amount, source: organization)
      end

      organization.credit_pool(amount: -100, source: organization)

      expect(organization.credit_total).to eq sum_cents
    end

    it 'should be nil for a new organization' do
      expect(organization.credit_total_cached).to eq nil
    end

    it 'updates credit total cache after commit' do
      organization.credit_pool(amount: 250, source: organization)
      expect(organization.credit_total).not_to eq nil
      expect(organization.credit_total_cached).to eq organization.credit_total
    end
  end

  context '#to_csv' do
    it 'returns a csv for a collection of credits' do
      csv = described_class.all.to_csv

      described_class.all.each do |credit|
        record = [
          credit.id,
          credit.source_type,
          credit.source_id,
          credit.amount,
          credit.amount_currency,
          credit.created_at,
          credit.updated_at,
          credit.organization_id
        ].join(',')

        expect(csv).to include record
        expect(csv).not_to match /translation missing/
      end
    end
  end
end
