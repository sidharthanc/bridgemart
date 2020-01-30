RSpec.describe Enrollment::MembersController, type: :controller do
  include ActiveJob::TestHelper

  let(:user) { users(:test) }
  let(:order) { orders(:metova) }
  let(:member) { members(:logan) }

  before do
    OrganizationUser.create(organization: order.organization, user: user)
    sign_in user
  end

  after do
    clear_enqueued_jobs
  end

  describe "POST add" do
    it "should add redirect to enrollment new page" do
      expect(
        post(:add, params: { order_id: order.id, member_id: member.id })
      ).to redirect_to new_enrollment_order_member_path(order, mode: :search)
    end

    it "should add members to orders" do
      post :add, params: { order_id: order.id, member_id: member.id }
      expect(order.members.exists?(member.id)).to eq true
    end
  end
end
