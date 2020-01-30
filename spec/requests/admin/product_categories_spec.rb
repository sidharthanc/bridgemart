describe 'Admin Product Categories', type: :request do
  let(:index) { AdminPages::Index.new(ProductCategory) }

  as { users(:andrew) }
  before do
    attach_images_to_product_categories
    index.visit
  end

  describe 'New' do
    let(:form) { index.new_form }
    before { index.navigate_to :new }

    it 'should successfully create the record' do
      form.fill_in_attributes name: 'a new name'
      form.fill_in_attributes product_bin: 'a new product bin'
      select Division.first.name, from: 'product_category[division_id]'
      select 'first_data', from: 'product_category[card_type]'
      form.attach_file 'product_category[image]', Rails.root.join('app', 'assets', 'images', 'missing-image.png')
      check 'product_category[use_organization_branding]'
      form.submit

      expect(page).to have_content t('flash.actions.create.notice', resource_name: 'Product category')
      expect(page).to have_content 'a new name'
      expect(page).to have_content 'a new product bin'
    end
  end

  describe 'Edit' do
    let(:form) { index.edit_form }
    before do
      within('.table_actions', match: :first) do
        click_on('Edit')
      end
    end

    it 'should successfully edit the record' do
      form.fill_in_attributes name: 'a new name'
      form.fill_in_attributes product_bin: 'a new product bin'
      select Division.first.name, from: 'product_category[division_id]'
      select 'first_data', from: 'product_category[card_type]'
      check 'product_category[use_organization_branding]'
      form.submit

      expect(page).to have_content t('flash.actions.update.notice', resource_name: 'Product category')
      expect(page).to have_content 'a new name'
      expect(page).to have_content 'a new product bin'
      expect(page).to have_content 'first_data'
    end

    it 'can edit a price point' do
      fill_in 'product_category[price_points_attributes][0][limit]', with: 123
      fill_in 'product_category[price_points_attributes][0][verbiage]', with: 'test'
      fill_in 'product_category[price_points_attributes][0][note]', with: 'test'
      fill_in 'product_category[price_points_attributes][0][tooltip]', with: 'test'
      fill_in 'product_category[price_points_attributes][0][upgrade_verbiage]', with: 'test'
      fill_in 'product_category[price_points_attributes][0][item_name]', with: 'test'

      form.submit
      expect(page).to have_content t('flash.actions.update.notice', resource_name: 'Product category')

      price_points(:fashion_opening).reload.tap do |pt|
        expect(pt.limit).to eq 123
        expect(pt.verbiage).to eq 'test'
        expect(pt.note).to eq 'test'
        expect(pt.tooltip).to eq 'test'
        expect(pt.upgrade_verbiage).to eq 'test'
        expect(pt.item_name).to eq 'test'
      end
    end

    it 'can mark a product category as single use only' do
      check 'product_category[single_use_only]'

      form.submit
      expect(page).to have_content t('flash.actions.update.notice', resource_name: 'Product category')

      expect(ProductCategory.last.single_use_only).to be true
    end

    it 'can mark a product category to use organization branding' do
      check 'product_category[use_organization_branding]'

      form.submit
      expect(page).to have_content t('flash.actions.update.notice', resource_name: 'Product category')

      expect(ProductCategory.last.use_organization_branding).to be true
    end

    it 'can mark a product category to have redemption instructions' do
      check 'product_category[redemption_instructions_editable]'

      form.submit
      expect(page).to have_content t('flash.actions.update.notice', resource_name: 'Product category')

      expect(ProductCategory.last.redemption_instructions_editable).to be true
    end
  end

  describe 'Delete' do
    let(:valid) { product_categories(:unused) }
    let(:invalid) { product_categories(:fashion) }

    it 'should allow us to delete new product categories' do
      expect(page).to have_content valid.name

      within "\#product_category_#{valid.id}" do
        click_on t('active_admin.delete')
      end

      expect(page).to have_content t('flash.actions.destroy.notice', resource_name: 'Product category')
      expect(page).to_not have_content valid.name
    end

    it 'throws an error when a product category is in use' do
      expect(page).to have_content invalid.name

      within "\#product_category_#{invalid.id}" do
        click_on t('active_admin.delete')
      end

      expect(page).to have_content invalid.name
      expect(page).to have_content invalid.id
    end

    describe 'Show' do
      before { index.show product_categories(:exam) }

      it 'shows the price points' do
        [price_points(:eye_exam), price_points(:contact_lens_fitting)].each do |pt|
          expect(page).to have_content pt.limit
          expect(page).to have_content pt.verbiage
          expect(page).to have_content pt.note
          expect(page).to have_content pt.tooltip
          expect(page).to have_content pt.upgrade_verbiage
          expect(page).to have_content pt.item_name
        end
      end
    end
  end
end
