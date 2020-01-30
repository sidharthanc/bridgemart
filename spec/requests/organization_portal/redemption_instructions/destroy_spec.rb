describe 'Destroying a redemption instruction', type: :request do
  let(:primary_user) { users(:joseph) }
  let(:broker_user) { users(:broker) }
  let(:admin_user) { users(:admin) }
  let(:organization) { organizations(:metova) }
  let(:instruction) { redemption_instructions(:fashion_instruction) }

  context 'admin user' do
    before do
      sign_in admin_user
      visit organization_redemption_instruction_path(organization, instruction)
    end

    it 'can view a redemption instruction under the current organization' do
      expect(page).to have_link(t('organization_portal.redemption_instructions.show.delete_instruction', href: organization_redemption_instruction_path(organization, instruction), method: :delete))
      expect do
        click_link(t('organization_portal.redemption_instructions.show.delete_instruction'), href: organization_redemption_instruction_path(organization, instruction))
      end.to change(RedemptionInstruction, :count).by(-1)
    end
  end

  context 'broker user' do
    before do
      sign_in broker_user
      broker_user.organizations << organization
      visit organization_redemption_instruction_path(organization, instruction)
    end

    it 'can view a redemption instruction under the current organization' do
      expect(page).to have_link(t('organization_portal.redemption_instructions.show.delete_instruction', href: organization_redemption_instruction_path(organization, instruction), method: :delete))
      expect do
        click_link(t('organization_portal.redemption_instructions.show.delete_instruction'), href: organization_redemption_instruction_path(organization, instruction))
      end.to change(RedemptionInstruction, :count).by(-1)
    end
  end

  context 'primary user' do
    before do
      sign_in primary_user
      primary_user.organizations << organization
      visit organization_redemption_instruction_path(organization, instruction)
    end

    it 'can view a redemption instruction under the current organization' do
      expect(page).to have_link(t('organization_portal.redemption_instructions.show.delete_instruction', href: organization_redemption_instruction_path(organization, instruction), method: :delete))
      expect do
        click_link(t('organization_portal.redemption_instructions.show.delete_instruction'), href: organization_redemption_instruction_path(organization, instruction))
      end.to change(RedemptionInstruction, :count).by(-1)
    end
  end
end
