RSpec.describe OrdersController, type: :controller do
  include ActiveJob::TestHelper

  let(:user) { users(:test) }
  let(:order) { orders(:metova) }
  let(:member) { members(:logan) }
  let(:unpaid_order) { orders(:metova_unpaid) }

  before do
    OrganizationUser.create(organization: unpaid_order.organization, user: user)
    sign_in user
  end

  after do
    clear_enqueued_jobs
  end

  describe "GET cancel" do
    it "should redirect_to organization orders page" do
      expect(
        post(:cancel, params: { organization_id: unpaid_order.organization.id, order_id: unpaid_order.id })
      ).to redirect_to organization_orders_path(unpaid_order.organization)
    end
  end
end
