describe 'Updating a redemption instruction', type: :request do
  let(:form) { RedemptionInstructionForm.new }
  let(:primary_user) { users(:joseph) }
  let(:broker_user) { users(:broker) }
  let(:admin_user) { users(:admin) }
  let(:unrelated_user) { users(:test_two) }
  let(:organization) { organizations(:metova) }
  let(:instruction) { redemption_instructions(:fashion_instruction) }
  let(:instruction_2) { redemption_instructions(:fashion_instruction_two) }

  context 'admin user' do
    before do
      sign_in admin_user
      instruction.update(active: true)
      visit edit_organization_redemption_instruction_path(organization, instruction)
    end

    it 'updates a redemption instruction under the current organization' do
      instruction_2.update(active: true)
      visit edit_organization_redemption_instruction_path(organization, instruction)
      fill_in "redemption_instruction[title]", with: 'Updated Title'
      uncheck 'redemption_instruction_active'
      expect do
        form.submit
        expect(page.current_path).to eq organization_redemption_instructions_path(organization)
      end.to_not change(organizations(:metova).redemption_instructions, :count)
      expect(instruction.reload.title).to eq('Updated Title')
      expect(instruction.reload.active).to be_falsy
    end

    it 'sets the redemption instruction as active if the active attribute was flagged as true' do
      visit edit_organization_redemption_instruction_path(organization, instruction_2)
      check 'redemption_instruction_active'
      form.submit
      expect(instruction_2.reload.active).to be true
    end

    it 'hides the active flag for last active instruction' do
      visit edit_organization_redemption_instruction_path(organization, instruction)
      expect(page).not_to have_selector("#redemption_instruction_active")
    end

    it 'shows the active flag for other active instruction' do
      instruction_2.update(active: true)
      visit edit_organization_redemption_instruction_path(organization, instruction)
      expect(page).to have_selector("#redemption_instruction_active")
    end

    it 'shows validation errors if invalid' do
      fill_in 'redemption_instruction[title]', with: ''
      expect do
        form.submit
        expect(page).to have_content "Title can't be blank"
      end.to_not change(organizations(:metova).redemption_instructions, :count)
    end

    it 'only shows product categories that have been flagges as having redemption instructions' do
      products = ProductCategory.where(redemption_instructions_editable: true).map(&:name)
      expect(page).to have_select('redemption_instruction_product_category_id', options: products)
    end
  end

  context 'broker user' do
    before do
      sign_in broker_user
      broker_user.organizations << organization
      visit edit_organization_redemption_instruction_path(organization, instruction)
      instruction.update(active: true)
    end

    it 'updates a redemption instruction under the current organization' do
      instruction_2.update(active: true)
      fill_in "redemption_instruction[title]", with: 'Updated Title'
      uncheck 'redemption_instruction_active'
      expect do
        form.submit
        expect(page.current_path).to eq organization_redemption_instructions_path(organization)
      end.to_not change(organizations(:metova).redemption_instructions, :count)
      expect(instruction.reload.title).to eq('Updated Title')
      expect(instruction.reload.active).to be_falsy
    end

    it 'sets the redemption instruction as active if the active attribute was flagged as true' do
      visit edit_organization_redemption_instruction_path(organization, instruction_2)
      check 'redemption_instruction_active'
      form.submit
      expect(instruction_2.reload.active).to be true
    end

    it 'shows validation errors if invalid' do
      fill_in 'redemption_instruction[title]', with: ''
      expect do
        form.submit
        expect(page).to have_content "Title can't be blank"
      end.to_not change(organizations(:metova).redemption_instructions, :count)
    end

    it 'only shows product categories that have been flagges as having redemption instructions' do
      products = ProductCategory.where(redemption_instructions_editable: true).map(&:name)
      expect(page).to have_select('redemption_instruction_product_category_id', options: products)
    end
  end

  context 'primary user' do
    before do
      sign_in primary_user
      primary_user.organizations << organization
      visit edit_organization_redemption_instruction_path(organization, instruction)
      instruction.update(active: true)
    end

    it 'updates a redemption instruction under the current organization' do
      instruction_2.update(active: true)
      fill_in "redemption_instruction[title]", with: 'Updated Title'
      uncheck 'redemption_instruction_active'
      expect do
        form.submit
        expect(page.current_path).to eq organization_redemption_instructions_path(organization)
      end.to_not change(organizations(:metova).redemption_instructions, :count)
      expect(instruction.reload.title).to eq('Updated Title')
      expect(instruction.reload.active).to be_falsy
    end

    it 'sets the redemption instruction as active if the active attribute was flagged as true' do
      visit edit_organization_redemption_instruction_path(organization, instruction_2)
      check 'redemption_instruction_active'
      form.submit
      expect(instruction_2.reload.active).to be true
    end

    it 'shows validation errors if invalid' do
      fill_in 'redemption_instruction[title]', with: ''
      expect do
        form.submit
        expect(page).to have_content "Title can't be blank"
      end.to_not change(organizations(:metova).redemption_instructions, :count)
    end

    it 'only shows product categories that have been flagges as having redemption instructions' do
      products = ProductCategory.where(redemption_instructions_editable: true).map(&:name)
      expect(page).to have_select('redemption_instruction_product_category_id', options: products)
    end
  end

  context 'as a non organization user' do
    before { sign_in unrelated_user }

    it 'the user is redirected to the root path' do
      visit edit_organization_redemption_instruction_path(organization, instruction)
      expect(page).to have_current_path root_path
      expect(page).to have_content 'You are not authorized to perform this action.'
    end
  end
end
