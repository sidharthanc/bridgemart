describe 'Members CSV export', type: :request do
  let(:organization) { organizations(:metova) }
  as { users(:joseph) }

  it 'downloads a member CSV' do
    visit organization_members_path(organization)
    click_on t('members.index.export.members')
    page.response_headers['Content-Disposition'].tap do |header|
      expect(header).to match /^attachment/
      expect(header).to match /filename="members-#{Date.current}.csv"$/
    end
  end

  it 'downloads an Usage CSV' do
    visit organization_members_path(organization)
    click_on t('members.index.export.usages')
    page.response_headers['Content-Disposition'].tap do |header|
      expect(header).to match /^attachment/
      expect(header).to match /filename="usages-#{Date.current}.csv"$/
    end
  end

  it 'exports the correct data in the CSV' do
    visit organization_members_path(organization)
    click_on t('members.index.export.members')
    expect(page).to have_content MemberExport.new(organization.members, organization).csv
  end

  it 'exports all members not just the ones on the page' do
    visit organization_members_path(organization, page: 1, per: 1)
    expect(page).to have_selector 'tr.tr-member[data-controller]'
    click_on t('members.index.export.members')
    expect(page).to have_content members(:logan).id
    expect(page).to have_content members(:kaleb).id
    expect(page).to have_content members(:angelita).id
  end

  it 'exports filtered results if the user was searching' do
    visit organization_members_path(organization)
    fill_in 'q_member_cont', with: members(:logan).first_name
    click_on 'member-search'
    click_on t('members.index.export.members')
    expect(page).to have_content MemberExport.new([members(:logan)], organization).csv
    expect(page).to have_no_content members(:kaleb).id
    expect(page).to have_no_content members(:angelita).id
  end

  it 'does not show export button if there are no members' do
    visit organization_members_path(organization)
    fill_in 'q_member_cont', with: 'a bunch of nonsense'
    click_on 'member-search'
    expect(page).to have_no_link t('members.index.export.members')
  end
end
