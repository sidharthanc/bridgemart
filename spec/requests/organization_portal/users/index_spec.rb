describe 'Users index page', type: :request do
  before do
    organizations(:metova).users += org_users
  end

  let!(:org_users) { [users(:test), users(:joseph)] }
  let(:user) { users(:joseph) }
  let(:organization) { organizations(:metova) }

  before do
    sign_in user
  end

  it 'is linked to on the nav bar in the header' do
    visit edit_organization_organization_path(organization)
    expect(page).to have_link t('layouts.organization_portal.nav.users'), href: organization_users_path(organization)
  end

  it 'shows each user' do
    visit organization_users_path(organization)
    org_users.each do |user|
      expect(page).to have_content user.full_name
    end
  end

  it 'has a link to view each user' do
    visit organization_users_path(organization)
    org_users.each do |user|
      expect(page).to have_link t('organization_portal.users.index.actions.view'), href: organization_user_path(organization, user)
    end
  end

  it 'has a link to add a new user' do
    visit organization_users_path(organization)
    expect(page).to have_link t('organization_portal.users.index.new_user'), href: new_organization_user_path(organization)
  end

  context 'with pagination' do
    it 'displays the number of total users (not number on current page)' do
      visit organization_users_path(organization, page: 1, per: 1)
      expect(page).to have_content "Count: #{organization.users.count}"
    end

    it 'paginates the user' do
      2.times { organization.users << User.all } # To populate the users count
      visit organization_users_path(organization, page: 1, per: 1)
      expect(page).to have_link 'Next', href: organization_users_path(organization, page: 2, per: 1)
    end
  end

  describe 'user search' do
    let(:user) { users(:test).tap { |x| x.update(phone_number: '(123) 456-6789') } }
    let(:user2) { users(:test_two) }

    before do
      visit organization_users_path(organization)
    end

    context 'has field and buttons for searching' do
      it 'shows a search field and buttons' do
        expect(page).to have_field 'q_user_cont', placeholder: t('helpers.search.placeholder')
        expect(page).to have_button 'user-search'
        expect(page).to have_link t('helpers.search.clear')
      end
    end

    context 'search for an existing user' do
      %i[first_name last_name phone_number email].each do |attribute|
        it "searches by #{attribute}" do
          fill_and_search_user(user.send(attribute))
          expect_user_on_page(user)
          expect(page).not_to have_content user2.full_name
        end
      end

      it 'searches by a partial first name' do
        fill_and_search_user(user.first_name[(user.first_name.length / 2)..-1])
        expect_user_on_page(user)
        expect(page).not_to have_content user2.first_name
      end
    end

    context 'search for a non-existing user' do
      it 'returns an empty table' do
        fill_and_search_user('a very non-existent user')
        expect(find('tbody')).to have_no_css('*')
      end
    end
  end

  context 'without privileges' do
    before { user.permission_groups = [permission_groups(:none)] }

    it 'should not show the new link' do
      expect(page).to have_no_link t('organization_portal.users.index.new_user'), href: new_organization_user_path(organization)
    end
  end
end

def expect_user_on_page(user)
  expect(page).to have_content user.id
  expect(page).to have_content user.full_name
  expect(page).to have_content user.email
  expect(page).to have_content user.phone_number
end

def fill_and_search_user(search)
  fill_in 'q_user_cont', with: search
  click_on 'user-search'
end
