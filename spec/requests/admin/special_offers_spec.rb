describe 'Admin Special Offers', type: :request do
  let(:index) { AdminPages::Index.new(SpecialOffer) }
  as { users(:andrew) }

  before do
    index.visit
  end

  describe 'New' do
    let(:form) { index.new_form }
    before { index.navigate_to :new }

    it 'should successfully create the record' do
      form.fill_in_attributes name: 'a new name'
      form.fill_in_attributes description: 'a new description'
      form.fill_in_attributes usage_instructions: 'some usage instructions'
      select ProductCategory.first.name, from: 'special_offer[product_category_id]'
      form.attach_file 'special_offer[image]', Rails.root.join('app', 'assets', 'images', 'missing-image.png')
      form.submit

      expect(page).to have_content t('flash.actions.create.notice', resource_name: 'Special offer')
      expect(page).to have_content 'a new name'
    end
  end

  describe 'Edit' do
    let(:form) { index.edit_form }
    before { index.navigate_to :edit }

    it 'should successfully edit the record' do
      form.fill_in_attributes name: 'a new name'
      form.fill_in_attributes description: 'a new description'
      form.fill_in_attributes usage_instructions: 'some usage instructions'
      select ProductCategory.first.name, from: 'special_offer[product_category_id]'
      form.attach_file 'special_offer[image]', Rails.root.join('app', 'assets', 'images', 'missing-image.png')
      form.submit

      expect(page).to have_content t('flash.actions.update.notice', resource_name: 'Special offer')
      expect(page).to have_content 'a new name'
    end
  end

  describe 'Delete' do
    let(:valid) { special_offers(:one) }
    let(:invalid) { special_offers(:two) }

    it 'should allow us to delete special offers' do
      expect(page).to have_content valid.name

      within "\#special_offer_#{valid.id}" do
        click_on t('active_admin.delete')
      end

      expect(page).to have_content t('flash.actions.destroy.notice', resource_name: 'Special offer')
      expect(page).to_not have_content valid.name
    end
  end
end
