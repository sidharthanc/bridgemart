describe "List a member's codes with token auth", type: :request do
  let(:member) { members(:logan) }

  it 'returns a 401 if no ID is provided' do
    visit mobile_codes_path token: member.authentication_token
    expect(page.status_code).to eq 401
  end

  it 'returns a 401 if no token is provided' do
    visit mobile_codes_path id: member.id
    expect(page.status_code).to eq 401
  end

  it "returns a 401 if the token doesn't match the record with the ID provided" do
    visit mobile_codes_path id: member.id, token: members(:kaleb).authentication_token
    expect(page.status_code).to eq 401
  end

  it "displays the member's codes" do
    member.codes.each { |code| code.update_code_with_remote_source }
    visit mobile_codes_path id: member.id, token: member.authentication_token
    member.codes.each do |code|
      expect(page).to have_content humanized_money_with_symbol(code.limit)
      expect(page).to have_link href: mobile_code_path(code, token: code.authentication_token)
    end
  end
end
