describe 'Redemption Instructions index', type: :request do
  let(:primary_user) { users(:joseph) }
  let(:broker_user) { users(:broker) }
  let(:admin_user) { users(:admin) }
  let(:organization) { organizations(:metova) }
  let(:instruction) { redemption_instructions(:fashion_instruction) }
  let(:instruction_2) { redemption_instructions(:fashion_instruction_two) }

  before { attach_images_to_product_categories }

  context 'as an admin user' do
    before { sign_in admin_user }

    it 'has a link on the nav bar in the header' do
      visit edit_organization_organization_path(organization)
      expect(page).to have_link t('layouts.organization_portal.nav.redemption_instructions'), href: organization_redemption_instructions_path(organization)
    end

    it 'can view all redemption instructions under the current organization' do
      visit organization_redemption_instructions_path(organization)
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.header'))
      expect(page).to have_link t('organization_portal.redemption_instructions.index.new_redemption_instruction')

      expect(page).to have_content(t('organization_portal.redemption_instructions.index.columns.product_category'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.columns.description'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.columns.instruction_title'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.columns.active_status'))

      organization.redemption_instructions.each do |ri|
        expect(page).to have_content(ri.product_category.name)
        expect(page).to have_content(ri.title)
        expect(page).to have_content(ri.description)
        expect(page).to have_content(ri.active?)

        expect(page).to have_link(t('organization_portal.redemption_instructions.index.actions.edit'), href: edit_organization_redemption_instruction_path(organization, ri))
      end
    end

    context 'when the product category does not allow redemption instructions to be set' do
      before do
        instruction.product_category.update(redemption_instructions_editable: false)
        visit organization_redemption_instructions_path(organization)
      end

      it 'shows none available message' do
        expect(page).to have_content(t('organization_portal.redemption_instructions.index.no_instructions_available'))
        expect(page).to have_no_link(t('organization_portal.redemption_instructions.index.new_redemption_instruction'), href: new_organization_redemption_instruction_path(organization))
      end
    end

    context 'when organization has no redemption instructions' do
      before do
        organization.redemption_instructions.destroy_all
        visit organization_redemption_instructions_path(organization)
      end

      it 'user sees none set message' do
        expect(page).to have_link(t('organization_portal.redemption_instructions.index.new_redemption_instruction'), href: new_organization_redemption_instruction_path(organization))
        expect(page).to have_content(t('organization_portal.redemption_instructions.index.no_instructions_set'))
      end
    end
  end

  context 'as a broker user' do
    before do
      sign_in broker_user
      broker_user.organizations << organization
    end

    it 'has a link on the nav bar in the header' do
      visit edit_organization_organization_path(organization)
      expect(page).to have_link t('layouts.organization_portal.nav.redemption_instructions'), href: organization_redemption_instructions_path(organization)
    end

    it 'can view all redemption instructions under the current organization' do
      visit organization_redemption_instructions_path(organization)
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.header'))
      expect(page).to have_link t('organization_portal.redemption_instructions.index.new_redemption_instruction')

      expect(page).to have_content(t('organization_portal.redemption_instructions.index.columns.product_category'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.columns.description'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.columns.instruction_title'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.columns.active_status'))

      organization.redemption_instructions.each do |ri|
        expect(page).to have_content(ri.product_category.name)
        expect(page).to have_content(ri.title)
        expect(page).to have_content(ri.description)
        expect(page).to have_content(ri.active?)

        expect(page).to have_link(t('organization_portal.redemption_instructions.index.actions.edit'), href: edit_organization_redemption_instruction_path(organization, ri))
      end
    end

    context 'when the product category does not allow redemption instructions to be set' do
      before do
        instruction.product_category.update(redemption_instructions_editable: false)
        visit organization_redemption_instructions_path(organization)
      end

      it 'shows none available message' do
        expect(page).to have_content(t('organization_portal.redemption_instructions.index.no_instructions_available'))
        expect(page).to have_no_link(t('organization_portal.redemption_instructions.index.new_redemption_instruction'), href: new_organization_redemption_instruction_path(organization))
      end
    end

    context 'when organization has no redemption instructions' do
      before do
        organization.redemption_instructions.destroy_all
        visit organization_redemption_instructions_path(organization)
      end

      it 'user sees none set message' do
        expect(page).to have_link(t('organization_portal.redemption_instructions.index.new_redemption_instruction'), href: new_organization_redemption_instruction_path(organization))
        expect(page).to have_content(t('organization_portal.redemption_instructions.index.no_instructions_set'))
      end
    end
  end

  context 'as a primary user' do
    before do
      sign_in primary_user
      primary_user.organizations << organization
    end

    it 'has a link on the nav bar in the header' do
      visit edit_organization_organization_path(organization)

      expect(page).to have_link t('layouts.organization_portal.nav.redemption_instructions'), href: organization_redemption_instructions_path(organization)
    end

    it 'can view all redemption instructions under the current organization' do
      visit organization_redemption_instructions_path(organization)
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.header'))
      expect(page).to have_link t('organization_portal.redemption_instructions.index.new_redemption_instruction')

      expect(page).to have_content(t('organization_portal.redemption_instructions.index.columns.product_category'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.columns.description'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.columns.instruction_title'))
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.columns.active_status'))

      organization.redemption_instructions.each do |ri|
        expect(page).to have_content(ri.product_category.name)
        expect(page).to have_content(ri.title)
        expect(page).to have_content(ri.description)
        expect(page).to have_content(ri.active?)

        expect(page).to have_link(t('organization_portal.redemption_instructions.index.actions.edit'), href: edit_organization_redemption_instruction_path(organization, ri))
      end
    end

    context 'when the product category does not allow redemption instructions to be set' do
      before do
        instruction.product_category.update(redemption_instructions_editable: false)
        visit organization_redemption_instructions_path(organization)
      end

      it 'shows none available message' do
        expect(page).to have_content(t('organization_portal.redemption_instructions.index.no_instructions_available'))
        expect(page).to have_no_link(t('organization_portal.redemption_instructions.index.new_redemption_instruction'), href: new_organization_redemption_instruction_path(organization))
      end
    end

    context 'when organization has no redemption instructions' do
      before do
        organization.redemption_instructions.destroy_all
        visit organization_redemption_instructions_path(organization)
      end

      it 'user sees none set message' do
        expect(page).to have_link(t('organization_portal.redemption_instructions.index.new_redemption_instruction'), href: new_organization_redemption_instruction_path(organization))
        expect(page).to have_content(t('organization_portal.redemption_instructions.index.no_instructions_set'))
      end
    end
  end

  context 'as a user of an org without any redemption instructions' do
    let(:user) { users(:andrew) }
    let(:org) { organizations(:bridge) }

    before do
      user.permission_groups = []
      sign_in user
    end

    it 'shows no instructions message' do
      visit organization_redemption_instructions_path(org)
      expect(page).to have_content(t('organization_portal.redemption_instructions.index.no_instructions_available'))
    end
  end
end
