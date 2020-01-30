describe 'Organizations', type: :request do
  let(:user) { users(:joseph) }
  let(:admin) { users(:andrew) }
  as { user }

  before { visit organizations_path }

  it 'shows a sign out link' do
    expect(page).to have_link I18n.t('layouts.organizations.sign_out')
  end

  describe 'admin link' do
    context 'as an admin' do
      as { admin }

      before { visit organizations_path }

      it 'shows the admin link' do
        expect(page).to have_link I18n.t('layouts.organizations.nav.admin')
      end
    end

    context 'as a non admin' do
      as { user }

      before { visit organizations_path }

      it 'does not show the admin link' do
        expect(page).to_not have_link I18n.t('layouts.organizations.nav.admin')
      end
    end
  end

  context 'broker user with multiple orgs' do
    before do
      user.permission_groups = [permission_groups(:broker)]
      user.organizations << organizations(:walmart)
      visit organizations_path
    end

    it 'show a new order link' do
      expect(page).to have_link I18n.t('shared.user_controls.new_order')
    end

    it 'shows each of the organizations that a user has' do
      expect(page).to have_content t('organizations.index.your_organizations')

      user.organizations.each do |organization|
        expect(page).to have_content organization.name
      end
    end

    it 'has a link to add an organization' do
      expect(page).to have_link I18n.t('organizations.index.add_an_organization')
    end

    it 'can visit any organzation dashboard it has access to' do
      user.organizations.each do |organization|
        visit organizations_path
        click_link(organization.name)
        expect(current_path).to eq dashboard_path
      end
    end

    it 'displays org info in a table for each organization that a broker has' do
      user.organizations.each do |organization|
        expect(page).to have_content t('organizations.index.columns.members')
        expect(page).to have_content organization.members_count
        expect(page).to have_content t('organizations.index.columns.account_status')
        expect(page).to have_content t("organizations.statuses.#{organization.account_status}")
        expect(page).to have_content t('organizations.index.columns.start_date')
        expect(page).to have_content l(organization.created_at, format: :mmddyyyy)
        expect(page).to have_content t('organizations.index.columns.ytd_load')
        expect(page).to have_content organization.ytd_load.format
      end
    end

    describe 'organizations search' do
      it 'shows a search field and buttons' do
        expect(page).to have_field 'q_name_cont', placeholder: I18n.t('helpers.search.placeholder')
        expect(page).to have_button 'organization-search'
        expect(page).to have_link t('helpers.search.clear')
      end

      it 'narrows search by organization name' do
        user.organizations.each do |organization|
          expect(page).to have_content organization.name
        end

        fill_in 'q_name_cont', with: user.organizations.first.name
        click_on 'organization-search'

        expect(page).to have_content user.organizations.first.name
        expect(page).to_not have_content user.organizations.last.name
      end

      it 'clears the search results' do
        fill_in 'q_name_cont', with: user.organizations.first.name
        click_on 'organization-search'

        expect(page).to have_content user.organizations.first.name
        expect(page).to_not have_content user.organizations.last.name

        click_link t('helpers.search.clear')

        user.organizations.each do |organization|
          expect(page).to have_content organization.name
        end
      end

      it 'does not explode with browser refresh' do
        fill_in 'q_name_cont', with: user.organizations.first.name
        click_on 'organization-search'

        expect(page).to have_content user.organizations.first.name
        expect(page).to_not have_content user.organizations.last.name

        page.driver.refresh

        expect(page).to have_content user.organizations.first.name
        expect(page).to_not have_content user.organizations.last.name
      end
    end

    context 'with pagination' do
      it 'does not paginate the organizations by default' do
        visit organizations_path
        expect(page).not_to have_link 'Next', href: organizations_path(page: 2, per: 1)
      end
    end
  end

  context 'admin' do
    before do
      user.permission_groups << permission_groups(:admin)
      visit organizations_path
    end

    it 'show a new order link' do
      expect(page).to have_link I18n.t('shared.user_controls.new_order')
    end

    it 'shows each of the organizations in the system' do
      fill_in 'q_name_cont', with: ''
      find('#organization-search').click
      expect(page).to have_content t('organizations.index.your_organizations')

      Organization.all.each do |organization|
        expect(page).to have_content organization.name
      end
    end

    it 'has a link to add an organization' do
      expect(page).to have_link I18n.t('organizations.index.add_an_organization')
    end

    it 'can visit any organzation dashboard' do
      Organization.all.each do |organization|
        visit organizations_path
        fill_in 'q_name_cont', with: organization.name
        find('#organization-search').click
        click_link(organization.name)
        expect(current_path).to eq dashboard_path
      end
    end

    it 'displays org info in a table for each organization' do
      fill_in 'q_name_cont', with: ''
      find('#organization-search').click
      Organization.all.each do |organization|
        expect(page).to have_content t('organizations.index.columns.members')
        expect(page).to have_content organization.members_count
        expect(page).to have_content t('organizations.index.columns.account_status')
        expect(page).to have_content t("organizations.statuses.#{organization.account_status}")
        expect(page).to have_content t('organizations.index.columns.start_date')
        expect(page).to have_content l(organization.created_at, format: :mmddyyyy)
        expect(page).to have_content t('organizations.index.columns.ytd_load')
        expect(page).to have_content organization.ytd_load.format
      end
    end

    context 'with pagination' do
      it 'does not paginate the organizations by default' do
        visit organizations_path
        expect(page).not_to have_link 'Next', href: organizations_path(page: 2, per: 1)
      end
    end
  end

  context 'as a non broker and non admin' do
    it 'does not have a link to add an organization' do
      expect(page).to_not have_link I18n.t('organizations.index.add_an_organization')
    end
  end

  context 'Organization Member Details' do
    let(:organization) { organizations(:metova) }
    before do
      visit organization_members_path(organization.id)
    end
    let!(:member) { members(:logan) }
    let(:used_code) { member.codes.create! limit: 50.to_money, balance: 10.to_money, external_id: :USED123, plan_product_category: plan_product_categories(:fashion) }
    let(:unused_code) { member.codes.create! limit: 50.to_money, balance: 50.to_money, external_id: :UNUSED123, plan_product_category: plan_product_categories(:fashion) }

    it "show list of organization members" do
      expect(find('#buttons-div')).to have_content('Members')
      expect(find('#buttons-div')).to have_content('Codes')
    end

    it "show all members codes", js: true do
      arr = [used_code, unused_code]
      click_link("Codes")
      arr.each do |data|
        expect(page).to have_content(data.id)
      end
    end

    it "show only used codes onchange of status codes dropdown", js: true do
      used_code
      page.execute_script("$('#status_codes_dropdown').show()")
      page.select("Used Codes", from: "code_status")
      expect(page).to have_content(used_code.id)
    end

    it "should not show unused codes when used code is selected", js: true do
      used_code
      page.execute_script("$('#status_codes_dropdown').show()")
      page.select("Used Codes", from: "code_status")
      expect(page).to_not have_content(unused_code.id)
    end

    it "show only unused codes onchange of status codes dropdown", js: true do
      unused_code
      page.execute_script("$('#status_codes_dropdown').show()")
      page.select("Unused Codes", from: "code_status")
      expect(page).to have_content(unused_code.id)
    end

    it "should not show used codes when unused code is selected", js: true do
      unused_code
      page.execute_script("$('#status_codes_dropdown').show()")
      page.select("Unused Codes", from: "code_status")
      expect(page).to_not have_content(used_code.id)
    end
  end
end
