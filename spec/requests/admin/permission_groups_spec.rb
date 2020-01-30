describe 'Admin Permission Groups', type: :request do
  as { users(:andrew) }

  let(:index) { AdminPages::Index.new(PermissionGroup) }
  before { index.visit }

  describe 'New' do
    let(:form) { index.new_form }
    before { index.navigate_to :new }

    it 'should successfully create the record' do
      form.fill_in_attributes name: 'New Group'
      form.submit

      expect(page).to have_content t('flash.actions.create.notice', resource_name: 'Permission group')
      expect(page).to have_content 'New Group'
    end
  end

  describe 'Edit' do
    let(:form) { index.edit_form }
    before { index.navigate_to :edit }

    it 'should successfully update the record' do
      form.fill_in_attributes name: 'Updated Group'
      form.submit

      expect(page).to have_content t('flash.actions.update.notice', resource_name: 'Permission group')
      expect(page).to have_content 'Updated Group'
    end
  end
end
