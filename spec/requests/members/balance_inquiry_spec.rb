describe 'Performs Balance Inquiry on a Member', type: :request do
  as { users(:joseph) }

  it 'does not have the balance inquiry link on a non-FirstData member' do
    member = members(:logan)
    visit organization_member_path(member.organization, member)
    expect(page).not_to have_link t('members.header.balance_inquiry')
  end

  it 'runs the balance inquiry on the member' do
    member = members(:kaleb)
    visit organization_member_path(member.organization, member)

    expect(ClosedLoop::Transactions::BalanceInquiry).to receive_message_chain(:new, :perform)
    click_on t('members.header.balance_inquiry')
  end
end
