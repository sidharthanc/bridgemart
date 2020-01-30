describe 'Viewing a redemption instruction', type: :request do
  let(:primary_user) { users(:joseph) }
  let(:broker_user) { users(:broker) }
  let(:admin_user) { users(:admin) }
  let(:unrelated_user) { users(:andrew) }
  let(:organization) { organizations(:metova) }
  let(:instruction) { redemption_instructions(:fashion_instruction) }

  context 'admin user' do
    before do
      sign_in admin_user
      visit organization_redemption_instruction_path(organization, instruction)
    end

    it 'can view a redemption instruction under the current organization' do
      expect(page).to have_content(t('organization_portal.redemption_instructions.show.product_category'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.show.instruction_title'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.show.instruction_description'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.show.instruction_active'))

      expect(page).to have_content(instruction.product_category.name)
      expect(page).to have_content(instruction.title)
      expect(page).to have_content(instruction.description)
      expect(page).to have_content(instruction.active?)
      expect(page).to have_link(t('organization_portal.redemption_instructions.show.delete_instruction', href: organization_redemption_instruction_path(organization, instruction), method: :delete))
    end
  end

  context 'broker user' do
    before do
      sign_in broker_user
      broker_user.organizations << organization
      visit organization_redemption_instruction_path(organization, instruction)
    end

    it 'can view a redemption instruction under the current organization' do
      expect(page).to have_content(t('organization_portal.redemption_instructions.show.product_category'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.show.instruction_title'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.show.instruction_description'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.show.instruction_active'))

      expect(page).to have_content(instruction.product_category.name)
      expect(page).to have_content(instruction.title)
      expect(page).to have_content(instruction.description)
      expect(page).to have_content(instruction.active?)
      expect(page).to have_link(t('organization_portal.redemption_instructions.show.delete_instruction', href: organization_redemption_instruction_path(organization, instruction), method: :delete))
    end
  end

  context 'primary user' do
    before do
      sign_in primary_user
      primary_user.organizations << organization
      visit organization_redemption_instruction_path(organization, instruction)
    end

    it 'can view a redemption instruction under the current organization' do
      expect(page).to have_content(t('organization_portal.redemption_instructions.show.product_category'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.show.instruction_title'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.show.instruction_description'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.show.instruction_active'))

      expect(page).to have_content(instruction.product_category.name)
      expect(page).to have_content(instruction.title)
      expect(page).to have_content(instruction.description)
      expect(page).to have_content(instruction.active?)
      expect(page).to have_link(t('organization_portal.redemption_instructions.show.delete_instruction', href: organization_redemption_instruction_path(organization, instruction), method: :delete))
    end
  end

  context 'as a non organization user' do
    before do
      attach_images_to_product_categories
      unrelated_user.permission_groups = []
      sign_in unrelated_user
    end

    it 'the user is redirected to the sign up path' do
      visit organization_redemption_instruction_path(organization, instruction)
      expect(page.current_path).to eq root_path
      expect(page).to have_content 'You are not authorized to perform this action.'
    end
  end
end
