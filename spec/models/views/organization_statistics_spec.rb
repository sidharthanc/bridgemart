RSpec.describe Views::OrganizationStatistics, type: :model do
  it { is_expected.to have_db_column(:id) }
  it { is_expected.to have_db_column(:organization_id) }
  it { is_expected.to have_db_column(:total_orders) }
  it { is_expected.to have_db_column(:total_members) }
  it { is_expected.to have_db_column(:total_load) }
  it { is_expected.to have_db_column(:total_balance) }
  
  describe 'data' do
    subject { described_class.all }

    let!(:organization) { create_list(:organization, 3) }
    let!(:order) { create_list(:order, 2, organization: organization.first) }
    let!(:second_org_order) { create(:order, organization: organization.second) }
    let!(:members) { create(:member, order: order.first) }
    # before { Views::OrganizationSummary.refresh } # Materialized

    it { is_expected.to be_present }
    #it { expect(subject.count).to be 3 }

    xdescribe 'find' do
      it do
        expect(subject.find(organization.id)).to have_attributes(id: organization.id, total_orders: 1, total_members: 1)
      end
    end
  end
end
