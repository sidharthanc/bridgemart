describe Overview do
  let(:all_organizations) { Overview.new(Organization.all) }
  let(:some_organizations) { Overview.new(Organization.where(id: Organization.pluck(:id).sample(2))) }
  let(:enrolled_for_all) { Organization.all.to_a.keep_if(&:enrolled?).count }
  let(:enrolled_for_some) { some_organizations.organizations.to_a.keep_if(&:enrolled?).count }
  let(:line_item_total) { LineItem.sum(&:amount) }
  let(:percent_used) { line_item_total / Usage.sum(&:amount) * 100.0 }
  let(:usage_total) { 200.0 }
  let(:members) { Member.joins(:organization) }
  let(:order) { Organization.joins(:orders).first.orders.first }

  describe 'Overview Initialization' do
    it 'returns an Overview object' do
      expect { all_organizations }.not_to raise_error
    end

    it 'raises ActiveRecord::RecordNotFound on no organizations' do
      expect { Overview.new(Organization.none) }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context '#count' do
    it 'all organizations' do
      expect(all_organizations.count).to eq Organization.count
    end

    it 'subset of organizations' do
      expect(some_organizations.count).to eq 2
    end
  end

  context '#enrolled' do
    it 'all organizations' do
      expect(all_organizations.enrolled).to eq enrolled_for_all

      Member.where(id: Organization.joins(:members).first.member_ids).destroy_all

      expect(Overview.new(Organization.all).enrolled).to eq enrolled_for_all - 1
    end

    it 'subset of organizations' do
      expect(some_organizations.enrolled).to eq enrolled_for_some
    end
  end

  context '#credit_total' do
    it 'has credit' do
      Organization.first.credits.create(source: Organization.first, amount: 100.45, created_at: Time.now)
      expect(all_organizations.credit_total).to eq 100.45.to_money
    end
  end

  context '#budget_total[_formatted]' do
    let(:budget) { PlanProductCategory.sum(&:budget) * members.count }
    let(:budget_text) { budget.format(no_cents: true) }

    it 'has the correct budget total' do
      expect(all_organizations.budget_total).to eq budget
    end

    it 'has the correct budget format' do
      expect(all_organizations.budget_total_formatted).to eq budget_text
    end
  end

  context '#budget_json' do
    let(:json) do
      [
        { 'name': 'Safety Eyewear', 'amount': 270, 'amount_formatted': '$270' },
        { 'name': 'Fashion Eyewear', 'amount': 435, 'amount_formatted': '$435' },
        { 'name': 'Eye Exam', 'amount': 180, 'amount_formatted': '$180' },
        { 'name': 'Remaining', 'amount': 685, 'amount_formatted': '$685' }
      ].as_json
    end

    it 'generates correct json' do
      expect(JSON.parse(all_organizations.budget_json)).to match_array json
    end
  end

  context '#orders_total' do
    it 'has the correct total' do
      expect(all_organizations.orders_total).to eq line_item_total
    end
  end

  context '#usage_percentage' do
    it 'has the correct percentage' do
      expect(all_organizations.usage_percentage).to eq 22.6
    end
  end

  context '#days_into_period' do
    let(:days) { 45 }

    it 'shows the highest days_into_period' do
      travel_to Time.zone.local(2018, 12, 31, 7, 0, 0) do
        order.starts_on = days.days.ago
        order.save(validate: false)
        # Organization.joins(:orders).first.orders.first.update starts_on: days.days.ago
        expect(all_organizations.days_into_period).to eq days
      end
    end
  end

  context '#members_without_usage_count' do
    let(:unused_members) { Member.joins(:organization).count - Member.joins(:usages).count }

    it 'shows the correct number of unused members' do
      expect(all_organizations.members_without_usage_count).to eq unused_members
    end
  end

  context '#members_usage_percentage_as_decimal' do
    let(:usage_percent) { Member.joins(:usages).count / Member.joins(:organization).count * 100.0 }

    it 'shows the correct usage percentage by members' do
      expect(all_organizations.members_usage_percentage_as_decimal).to eq usage_percent
    end
  end

  context '#usages_get_types' do
    it 'has the correct json' do
      expect(all_organizations.usages_get_types).to eq [divisions(:bridge_vision).name]
    end
  end

  context '#usages_build_stacked_area_data' do
    it 'has the correct json' do
      expect(all_organizations.usages_build_stacked_area_data).to eq [{ date: '02/02/2002', 'Bridge Vision' => usage_total }]
    end
  end

  context '#usage_total' do
    it 'has the correct total' do
      expect(all_organizations.usage_total).to eq usage_total.to_money
    end
  end

  context '#unpaid_orders_total' do
    let(:sample_order) { Order.all.sample }

    before do
      sample_order.update paid_at: nil
      sample_order.members << members.last
      sample_order.line_items << LineItem.new(order: sample_order, amount: 123.45)
    end

    it 'shows the total unpaid' do
      expect(all_organizations.unpaid_orders_total).to eq 123.45.to_money
    end
  end

  context '#orders' do
    it 'shows the orders collection' do
      expect(all_organizations.orders).to match_array Order.paid.active
    end
  end

  context '#members' do
    it 'shows the members collection' do
      expect(all_organizations.members).to match_array Member.joins(:order).all
    end
  end
end
