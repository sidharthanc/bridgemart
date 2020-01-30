describe 'Adding a redemption instruction', type: :request do
  let(:form) { RedemptionInstructionForm.new }
  let(:primary_user) { users(:joseph) }
  let(:broker_user) { users(:broker) }
  let(:admin_user) { users(:admin) }
  let(:unrelated_user) { users(:test_two) }
  let(:organization) { organizations(:metova) }
  let(:old_instruction) { redemption_instructions(:fashion_instruction) }

  context 'admin user' do
    before do
      sign_in admin_user
      visit new_organization_redemption_instruction_path(organization)
      old_instruction.update(active: true)
    end

    it 'creates a new redemption instruction under the current organization' do
      form.fill
      expect do
        form.submit
        expect(page.current_path).to eq organization_redemption_instructions_path(organization)
      end.to change(organizations(:metova).redemption_instructions, :count).by 1
    end

    it 'sets the redemption instruction as active if the active attribute was flagged as true' do
      form.fill
      check 'redemption_instruction_active'
      form.submit
      RedemptionInstruction.last.tap do |redemption_instruction|
        expect(redemption_instruction.active).to be true
      end
    end

    it 'shows validation errors if invalid' do
      form.fill
      fill_in 'redemption_instruction[title]', with: ''
      expect do
        form.submit
        expect(page).to have_content "Title can't be blank"
      end.to_not change(organizations(:metova).redemption_instructions, :count)
    end

    it 'only shows product categories that have been flagged as having redemption instructions' do
      products = ProductCategory.where(redemption_instructions_editable: true).map(&:name)
      expect(page).to have_select('redemption_instruction_product_category_id', options: products)
    end
  end

  context 'broker user' do
    before do
      sign_in broker_user
      broker_user.organizations << organization
      visit new_organization_redemption_instruction_path(organization)
      old_instruction.update(active: true)
    end

    it 'creates a new redemption instruction under the current organization' do
      form.fill
      expect do
        form.submit
        expect(page.current_path).to eq organization_redemption_instructions_path(organization)
      end.to change(organizations(:metova).redemption_instructions, :count).by 1
    end

    it 'sets the redemption instruction as active if the active attribute was flagged as true' do
      form.fill
      check 'redemption_instruction_active'
      form.submit
      RedemptionInstruction.last.tap do |redemption_instruction|
        expect(redemption_instruction.active).to be true
      end
    end

    it 'shows validation errors if invalid' do
      form.fill
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
      visit new_organization_redemption_instruction_path(organization)
      old_instruction.update(active: true)
    end

    it 'creates a new redemption instruction under the current organization' do
      form.fill
      expect do
        form.submit
        expect(page.current_path).to eq organization_redemption_instructions_path(organization)
      end.to change(organizations(:metova).redemption_instructions, :count).by 1
    end

    it 'sets the redemption instruction as active if the active attribute was flagged as true' do
      form.fill
      check 'redemption_instruction_active'
      form.submit
      RedemptionInstruction.last.tap do |redemption_instruction|
        expect(redemption_instruction.active).to be true
      end
    end

    it 'shows validation errors if invalid' do
      form.fill
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

  context 'as non-admin user' do
    before { sign_in unrelated_user }

    it 'redirects the non-admin user to the root path' do
      visit new_organization_redemption_instruction_path(organization)
      expect(page).to have_current_path root_path
      expect(page).to have_content 'You are not authorized to perform this action.'
    end
  end
end
