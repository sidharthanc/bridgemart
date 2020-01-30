RSpec.describe MembersController, type: :controller do
  let(:user) { users(:test) }
  let(:member) { members(:logan) }

  before do
    OrganizationUser.create(organization: member.organization, user: user)
    sign_in user
  end
  describe "GET deactivate" do
    it "should deactivate the member,codes, and send email to member to and redirect to organization member path  " do
      expect do
        patch :deactivate, params: { organization_id: member.organization.id, id: member.id }
      end.to have_enqueued_job.on_queue('mailers')
    end
  end
end
