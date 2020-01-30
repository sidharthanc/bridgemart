describe 'Updating a member', type: :request do
  let(:form) { MemberForm.new }
  let(:member) { members(:logan) }
  let(:out_of_org_member) { members(:bread) }
  let(:organization) { organizations(:metova) }

  as { users(:joseph) }

  it 'updates the member attributes' do
    visit edit_organization_member_path(organization, member)
    fill_in 'member[first_name]', with: 'Updated'
    fill_in 'member[external_member_id]', with: '123NewId'
    expect do
      form.submit
      expect(page.current_path).to eq organization_member_path(organization, member)
      expect(member.reload.external_member_id).to eq('123NewId')
    end.to change {
      member.reload.first_name
    }.to 'Updated'
  end

  it 'masks the phone number input', js: true do
    visit edit_organization_member_path(organization, member)
    fill_in 'member[phone]', with: '9999999999'
    expect do
      form.submit
      expect(page.current_path).to eq organization_member_path(organization, member)
    end.to change {
      member.reload.phone
    }.to '(999) 999-9999'
  end

  it 'does not display a usage alert if the user has no usage' do
    member.codes.each { |code| code.usages.destroy_all }
    visit edit_organization_member_path(organization, member)
    expect(page).to have_no_content t('members.usages_alert')
  end

  it 'does not allow the user to view members from other orgs' do
    expect do
      visit edit_organization_member_path(organization, out_of_org_member)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  context 'member has used their card' do
    before do
      codes(:logan).usages.create amount: 5.to_money
    end

    it 'displays a message informing the user that the member has usage' do
      visit edit_organization_member_path(organization, member)
      within '.alert' do
        expect(page).to have_content t('members.usages_alert')
      end
    end
  end
end
