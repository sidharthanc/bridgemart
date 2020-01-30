describe 'Admin Users', type: :request do
  let(:index) { AdminPages::Index.new(User) }

  as { users(:andrew) }
  before { index.visit }

  describe 'New' do
    let(:form) { index.new_form }
    before { index.navigate_to :new }

    it 'should successfully create the record' do
      form.fill_in_attributes(
        first_name: 'Bob',
        last_name: 'User',
        email: 'bob.user@example.com',
        password: 'password',
        password_confirmation: 'password'
      )

      form.submit

      expect(page).to have_content t('flash.actions.create.notice', resource_name: 'User')
      expect(page).to have_content 'bob.user@example.com'
    end
  end

  describe 'Show' do
    before { index.navigate_to :view }

    describe 'allowed actions' do
      it 'should show the delete link' do
        expect(page).to have_link 'Delete User'
      end
    end

    describe 'Delete' do
      it 'should allow us to delete organization' do
        expect do
          click_link('Delete User')
        end.to change(User, :count).by(-1)
      end
    end
  end

  describe 'Edit' do
    let(:form) { index.edit_form }
    before { index.navigate_to :edit }

    it 'should successfully edit the record' do
      form.fill_in_attributes(email: 'new.user@example.com')
      form.submit

      expect(page).to have_content t('flash.actions.update.notice', resource_name: 'User')
      expect(page).to have_content 'new.user@example.com'
    end

    it 'should be able to assign permission groups' do
      select permission_groups(:admin).name
      form.submit

      expect(page).to have_content permission_groups(:admin).name
    end

    it 'should restrict permission groups not owned by the current user' do
      expect(page).to have_content permission_groups(:admin).name
      expect(page).to have_content permission_groups(:organization).name
      expect(page).to have_no_content permission_groups(:none).name
    end

    it 'should be able to remove permission groups' do
      unselect permission_groups(:organization).name
      form.submit

      expect(page).to have_no_content permission_groups(:organization).name
    end
  end
end
