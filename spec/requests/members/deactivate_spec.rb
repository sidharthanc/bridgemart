describe 'De-activate a member', type: :request do
  let(:form) { MemberForm.new }
  let(:member) { members(:logan) }
  let(:organization) { organizations(:metova) }

  as { users(:joseph) }

  it 'redirects to the member details screen' do
    visit organization_member_path(organization, member)
    click_on t('members.header.deactivate')
    expect(page.current_path).to eq organization_member_path(organization, member)
  end

  it 'de-activates the member' do
    visit organization_member_path(organization, member)
    click_on t('members.header.deactivate')
    expect(page).to have_content t('inactive')
    expect(member.reload).to be_inactive
  end

  it 'deactivates the member codes' do
    visit organization_member_path(organization, member)
    click_on t('members.header.deactivate')
    expect(page).to have_content t('inactive')
    expect(member.reload.codes).to be_all(&:inactive?)
  end

  it 'is not linked to if they are already inactive' do
    member.deactivate
    visit organization_member_path(organization, member)
    expect(page).to have_no_link t('members.header.deactivate')
  end

  it 'must confirm the pop-up before de-activating', js: true do
    visit organization_member_path(organization, member)
    accept_confirm { click_on t('members.header.deactivate') }
    expect(page).to have_content t('inactive').upcase
    expect(member.reload).to be_inactive
  end
end
