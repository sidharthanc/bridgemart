describe 'Admin Permissions', type: :request do
  as { users(:andrew) }

  let(:index) { AdminPages::Index.new(Permission, parent: permission_groups(:organization)) }
  before { index.visit }

  describe 'New' do
    let(:form) { index.new_form }
    before { index.navigate_to :new }

    it 'should successfully create the record' do
      select 'plan', from: form.field_name(:target)
      check form.field_name(:create_permitted)
      form.submit

      expect(page).to have_content t('flash.actions.create.notice', resource_name: 'Permission')
    end
  end

  describe 'Edit' do
    let(:form) { index.edit_form }
    before { index.navigate_to :edit }

    it 'should successfully update the record' do
      select 'plan', from: form.field_name(:target)
      check form.field_name(:create_permitted)
      form.submit

      expect(page).to have_content t('flash.actions.update.notice', resource_name: 'Permission')
    end
  end
end
