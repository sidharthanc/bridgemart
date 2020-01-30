describe Dashboard::Budget do
  subject { described_class.new categories: categories }
  let(:categories) { Dashboard::Category.wrap_all plan.plan_product_categories }
  let(:plan) { plans(:metova) }

  describe '#total' do
    let(:exam_budget) { plan_product_categories(:exam).budget.to_i }
    let(:fashion_budget) { plan_product_categories(:fashion).budget.to_i }
    let(:safety_budget) { plan_product_categories(:safety).budget.to_i }

    it 'should be the sum of all category amounts' do
      expect(subject.total.to_i).to eq (exam_budget + fashion_budget + safety_budget) * plan.members_count
    end
  end

  context 'with no categories' do
    let(:subject) { described_class.new categories: [] }

    it 'returns an empty Money object from #total' do
      expect(subject.total).to be_a_kind_of Money
      expect(subject.total).to eq 0
    end

    it 'formats the total to $0' do
      expect(subject.total_formatted).to eq '$0'
    end
  end

  describe '#show?' do
    context 'with no categories' do
      let(:subject) { described_class.new categories: [] }

      it 'should not show' do
        expect(subject.show?).to be false
      end
    end

    context 'with a $0 total' do
      before { plan.plan_product_categories.update_all budget_cents: 0 }

      it 'should not show' do
        expect(subject.show?).to be false
      end
    end

    context 'with a total greater than $0' do
      before { Member.counter_culture_fix_counts }
      it 'should show' do
        expect(subject.show?).to be true
      end
    end
  end

  describe '#consolidate_categories' do
    let!(:duplicate_categories) { Dashboard::Category.wrap_all plan.plan_product_categories.map(&:dup).each(&:save) }
    before do
      duplicate_categories.each do |dup|
        categories << dup
      end
      Member.counter_culture_fix_counts
      subject.reload
    end

    it 'combines sums for duplicate categories' do
      expect(subject.consolidate_categories).to eq([
                                                     { name: 'Eye Exam', amount: 360, amount_formatted: '$360' },
                                                     { name: 'Fashion Eyewear', amount: 870, amount_formatted: '$870' },
                                                     { name: 'Safety Eyewear', amount: 540, amount_formatted: '$540' }
                                                   ])
    end
  end
end
