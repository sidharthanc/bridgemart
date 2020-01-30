describe 'Members index page', type: :request do
  let(:organization) { organizations(:metova) }
  as { users(:joseph) }

  it 'is linked to on the sidebar' do
    visit root_path
    within '.dashboard-nav' do
      expect(page).to have_link 'Members', href: organization_members_path(organization)
    end
  end

  it 'shows each member ID, name, phone, e-mail' do
    visit organization_members_path(organization)
    [members(:logan), members(:kaleb), members(:angelita)].each do |member|
      expect_member_on_page(member)
    end
  end

  describe 'member search' do
    let(:member) { members(:logan) }
    let(:member2) { members(:kaleb) }

    before do
      visit organization_members_path(organization)
    end

    context 'has field and buttons for searching' do
      it 'shows a search field and buttons' do
        expect(page).to have_field 'q_member_cont', placeholder: I18n.t('helpers.search.placeholder')
        expect(page).to have_button 'member-search'
        expect(page).to have_link I18n.t('helpers.search.clear')
      end
    end

    context 'search for an existing member' do
      %i[first_name last_name phone email].each do |attribute|
        it "searches by #{attribute}" do
          fill_and_search(member.send(attribute))
          expect_member_on_page(member)
          expect(page).not_to have_content member2.name
        end
      end

      it 'searches by a partial first name' do
        fill_and_search(member.first_name[0..(member.first_name.length / 2)])
        expect_member_on_page(member)
        expect(page).not_to have_content member2.name
      end
    end

    context 'search for a non-existing member' do
      it 'returns an empty table' do
        fill_and_search('a very non-existent member')
        expect(find('tbody')).to have_no_css('*')
      end
    end
  end

  it 'has a link to edit each member', js: true do
    visit organization_members_path(organization)
    find('td', text: members(:logan).name).click
    expect(page).to have_link I18n.t('members.member.actions.edit'), href: edit_organization_member_path(organization, members(:logan))
  end

  it 'has a link to resend codes to each member', js: true do
    visit organization_members_path(organization)
    find('td', text: members(:logan).name).click
    expect(page).to have_link I18n.t('members.member.actions.resend'), href: resend_organization_member_path(organization, members(:logan))
  end

  it 'sends an email to the member when clicked', js: true do
    visit organization_members_path(organization)
    find('td', text: members(:logan).name).click
    expect do
      page.accept_confirm do
        click_on t('members.member.actions.resend')
      end
    end.to have_enqueued_job.on_queue('mailers')
  end

  it 'has a link to de-activate each member', js: true do
    visit organization_members_path(organization)
    find('td', text: members(:logan).name).click
    expect(page).to have_link I18n.t('members.member.actions.deactivate'), href: deactivate_organization_member_path(organization, members(:logan))
  end

  it 'has a link to re-activate if member is inactive', js: true do
    members(:logan).deactivate
    visit organization_members_path(organization)
    find('td', text: members(:logan).name).click
    expect(page).to have_link I18n.t('members.member.actions.reactivate'), href: reactivate_organization_member_path(organization, members(:logan))
  end

  it 'does not have a link to de-activate a member that is already inactive', js: true do
    members(:logan).deactivate
    visit organization_members_path(organization)
    find('td', text: members(:logan).name).click
    expect(page).to have_no_link I18n.t('members.index.actions.deactivate'), href: deactivate_organization_member_path(organization, members(:logan))
  end

  it 'does not have a link to re-activate a member that is already active', js: true do
    visit organization_members_path(organization)
    find('td', text: members(:logan).name).click
    expect(page).to have_no_link I18n.t('members.member.actions.reactivate'), href: reactivate_organization_member_path(organization, members(:logan))
  end

  context 'with pagination' do
    it 'displays the number of total users (not number on current page)' do
      Member.counter_culture_fix_counts
      visit organization_members_path(organization, page: 1, per: 1)
      expect(page).to have_content 'Count: 3'
    end

    it 'does not paginate limited users' do
      visit organization_members_path(organization, page: 1, per: 1)
      expect(page).to have_selector '.index-table .tr-member-data.tr-expanded'
      expect(page).not_to have_link 'Next', href: organization_members_path(organization, page: 2, per: 1)
    end
  end

  it 'has a link to add a new member' do
    visit organization_members_path(organization)
    expect(page).to have_link I18n.t('members.index.new_member'), href: new_organization_enrollment_sign_up_path(organization)
  end

  describe 'usage' do
    let(:member) { members(:logan) }

    context 'with usage' do
      let(:used_at) { 1.hour.ago }

      let!(:usage) do
        Usage.create(
          code: codes(:logan),
          amount: 10.to_money,
          external_id: 'ABCD1234',
          used_at: used_at
        )
      end

      it 'expands to show the member usage', js: true do
        visit organization_members_path(organization)
        within('.index-table') do
          expect(page).to have_no_content 'Usage'
        end
        find('td', text: member.name).click
        click_on 'View Codes'
        within('.index-table') do
          find('td', text: member.codes.last.external_id).click
          expect(page).to have_content 'Usage'
          expect(page).to have_content '$10'
          expect(page).to have_content usage.code_identifier
          expect(page).to have_content l(usage.used_at, format: :mmddyyyy)
        end
      end
    end

    context 'without usage' do
      before do
        member.codes.each { |code| code.usages.destroy_all }
      end

      it 'says the member has no usage', js: true do
        visit organization_members_path(organization)
        within('.index-table') do
          expect(page).to have_no_content 'Usage'
        end
        find('td', text: member.name).click
        click_on 'View Codes'
        within('.index-table') do
          find('td', text: member.codes.last.external_id).click
          expect(page).to have_content t('usages.table.no_usage')
        end
      end
    end
  end
end

def expect_member_on_page(member)
  expect(page).to have_content member.id
  expect(page).to have_content member.name
  expect(page).to have_content member.email
  expect(page).to have_content member.phone
end

def fill_and_search(search)
  fill_in 'q_member_cont', with: search
  click_on 'member-search'
end
