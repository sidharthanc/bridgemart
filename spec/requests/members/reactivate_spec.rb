describe 'Re-activate a member', type: :request do
  let(:form) { MemberForm.new }
  let(:member) { members(:logan) }
  let(:organization) { organizations(:metova) }

  as { users(:joseph) }

  it 'redirects to the member details screen' do
    member.deactivate
    visit organization_member_path(organization, member)
    click_on t('members.header.reactivate')
    expect(page.current_path).to eq organization_member_path(organization, member)
  end

  it 're-activates the member' do
    member.deactivate
    visit organization_member_path(organization, member)
    click_on t('members.header.reactivate')
    expect(page).to_not have_content t('inactive').upcase
    expect(member.reload).to be_active
  end

  it 'is not linked to if they are already active' do
    visit organization_member_path(organization, member)
    expect(page).to have_no_link t('members.header.reactivate')
  end

  it 'must confirm the pop-up before de-activating', js: true do
    member.deactivate
    visit organization_member_path(organization, member)
    accept_confirm { click_on t('members.header.reactivate') }
    expect(page).to_not have_content t('inactive').upcase
    expect(member.reload).to be_active
  end
end
