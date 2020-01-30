describe 'User show page', type: :request do
  before do
    organizations(:metova).users << users(:test)
    organizations(:metova).users << users(:joseph)
  end

  as { user }
  let(:user) { users(:joseph) }
  let(:organization) { organizations(:metova) }

  it 'shows details for a user' do
    visit organization_user_path(organization, user)
    expect(page).to have_content user.full_name
  end

  it 'has a link to return back to the dashboard' do
    visit organization_user_path(organization, user)
    expect(page).to have_link I18n.t('organization_portal.users.show.nav.back'), href: organization_users_path(organization)
  end

  it 'has a link to edit the user' do
    visit organization_user_path(organization, user)
    expect(page).to have_link I18n.t('organization_portal.users.show.edit_link'), href: edit_organization_user_path(organization, user)
  end

  context 'without privileges' do
    before { users(:joseph).permission_groups = [permission_groups(:none)] }

    it 'should not show the edit link' do
      expect(page).to have_no_link I18n.t('organization_portal.users.show.edit_link'), href: edit_organization_user_path(organization, user)
    end
  end
end
