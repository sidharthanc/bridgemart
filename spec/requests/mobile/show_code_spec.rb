describe 'Display a singular code with token auth', type: :request do
  let(:code) { codes(:logan) }
  let(:member) { code }
  let!(:recemption_instruction) do
    RedemptionInstruction.create!(
      product_category: code.product_category,
      organization: code.organization,
      title: 'Title',
      description: 'Custom Redemption Instruction',
      active: true
    )
  end

  before { Backfill::CodeExpiresStartsOn.perform_now }

  it 'returns a 401 if no token is provided' do
    visit mobile_code_path code
    expect(page.status_code).to eq 401
  end

  it "returns a 401 if the token doesn't match the record with the ID provided" do
    visit mobile_code_path code, token: SecureRandom.hex
    expect(page.status_code).to eq 401
  end

  it 'displays the code limit' do
    visit mobile_code_path code, token: code.authentication_token
    expect(page).to have_content humanized_money_with_symbol(code.limit)
  end

  context 'enqueues a job to fetch the code barcode/image URLs' do
    it 'for EML' do
      expect do
        visit mobile_code_path code, token: code.authentication_token
      end.to enqueue_job(EML::CardOneTimeUrlsJob).with(code)
    end

    # NOTE: CardOneTimeUrlsJob Removed
    xit 'for First Data' do
      code.update! product_category: product_categories(:fashion)

      expect do
        visit mobile_code_path code, token: code.authentication_token
      end.to enqueue_job(FirstData::CardOneTimeUrlsJob).with(code)
    end
  end

  it 'displays the barcode once fetched', js: true do
    visit mobile_code_path code, token: code.authentication_token
    expect(page).to have_no_selector '.barcode-iframe'
    code.update barcode_url: '/test-iframe.html', card_image_url: '/test-iframe.html'
    within_frame 'barcode-iframe' do
      expect(page).to have_content File.read(Rails.root.join('public', 'test-iframe.html'))
    end
  end

  it 'displays the card number, CVV, and exp date once fetched', js: true do
    visit mobile_code_path code, token: code.authentication_token
    expect(page).to have_no_selector '.card-iframe'
    code.update barcode_url: '/test-iframe.html', card_image_url: '/test-iframe.html'
    within_frame 'card-iframe' do
      expect(page).to have_content File.read(Rails.root.join('public', 'test-iframe.html'))
    end
  end

  it 'displays the redemption_instructions' do
    visit mobile_code_path code, token: code.authentication_token
    expect(code.redemption_instructions).to be_present
    code.redemption_instructions.each do |instruction|
      expect(page).to have_content instruction.description
    end
  end

  describe 'as JSON' do
    context 'does not enqueue a job to fetch the URLs' do
      it 'for EML' do
        expect do
          visit mobile_code_path code, token: code.authentication_token
          expect(page.status_code).to eq 200
        end.to_not enqueue_job(EML::CardOneTimeUrlsJob)
      end

      xit 'for First Data' do
        expect do
          visit mobile_code_path code, token: code.authentication_token, format: :json
          expect(page.status_code).to eq 200
        end.to_not enqueue_job(FirstData::CardOneTimeUrlsJob)
      end
    end

    it 'removes the barcode/card image URLs from the DB after displaying them' do
      code.update barcode_url: '/test-iframe.html', card_image_url: '/test-iframe.html'

      expect do
        visit mobile_code_path code, token: code.authentication_token
      end.to change {
        code.reload
        [code.barcode_url, code.card_image_url]
      }.to [nil, nil]
    end
  end
end
