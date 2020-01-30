describe 'De-activate a code', type: :request do
  let(:form) { MemberForm.new }
  let(:member) { members(:logan) }
  let(:code) { codes(:logan) }
  let(:organization) { organizations(:metova) }

  as { users(:joseph) }

  it 'redirects to the member codes screen' do
    visit organization_member_codes_path(organization, member)
    deactivate_code
    expect(page.current_path).to eq organization_member_codes_path(organization, member)
  end

  it 'de-activates the code' do
    visit organization_member_codes_path(organization, member)
    expect do
      deactivate_code
      within('.index-table') do
        expect(page).to have_no_link t('codes.deactivate')
      end
      expect(code.reload).to be_inactive
      expect(code).to be_deactivated
    end.to enqueue_job(Cards::UnloadJob).with(code, code.balance.to_s)
  end

  it 'is not linked to if they are already inactive' do
    code.deactivate
    visit organization_member_codes_path(organization, member)
    within '.index-table' do
      expect(page).to have_no_link t('codes.deactivate')
    end
  end

  it 'must confirm the pop-up before de-activating', js: true do
    visit organization_member_codes_path(organization, member)
    accept_confirm { deactivate_code }
    within('.index-table') do
      expect(page).to have_no_link t('codes.deactivate')
    end
    expect(code.reload).to be_inactive
  end

  def deactivate_code
    within('.index-table') { click_on t('codes.deactivate') }
  end
end
