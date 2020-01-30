describe 'Viewing member codes', type: :request do
  as { users(:joseph) }
  let!(:member) { members(:logan) }
  let!(:organization) { organizations(:metova) }

  before { attach_images_to_product_categories }

  it 'is linked to on the member page' do
    visit organization_member_path(organization, member)
    expect(page).to have_link t('members.header.codes'), href: organization_member_codes_path(organization, member)
  end

  it 'activates the "Codes" link in the header' do
    visit organization_member_codes_path(organization, member)
    within '.dashboard-header .active' do
      expect(page).to have_content t('members.header.codes')
    end
  end

  it "lists the member's codes" do
    code1 = codes(:logan)
    code2 = member.codes.create! limit: 50.to_money, status: :activated, external_id: :ACTIVATED123, plan_product_category: plan_product_categories(:fashion)
    visit organization_member_codes_path(organization, member)

    [code1, code2].each do |code|
      expect(page).to have_content code.code_identifier
      expect(page).to have_content humanized_money_with_symbol(code.balance)
      expect(page).to have_content t("codes.statuses.#{code.status}")
    end

    expect(page).to have_no_content t('codes.legacy')
  end

  it 'searches the list of codes' do
    code1 = codes(:logan)
    code2 = member.codes.create! limit: 50.to_money, status: :activated, external_id: :ACTIVATED123, plan_product_category: plan_product_categories(:fashion)
    visit organization_member_codes_path(organization, member)
    expect(page).to have_content code1.code_identifier
    expect(page).to have_content code2.code_identifier

    fill_in 'q_product_category_name_or_balance_cents_or_order_id_or_id_or_external_id_cont', with: code1.external_id
    click_on 'member-search'

    expect(page).to have_content code1.code_identifier
    expect(page).not_to have_content code2.code_identifier
  end

  it 'marks the codes as delivered if delivered' do
    visit organization_member_codes_path(organization, member)
    expect(first("input[type='checkbox']")[:checked]).to eq false
    codes(:logan).delivered!
    visit organization_member_codes_path(organization, member)
    expect(first("input[type='checkbox']")[:checked]).to eq true
  end

  it 'marks inactive codes as inactive' do
    codes(:logan).deactivate
    visit organization_member_codes_path(organization, member)
    within('.index-table') do
      expect(page).to have_no_link t('codes.deactivate')
    end
  end

  it 'legacy codes are flagged as "legacy"' do
    codes(:logan).update legacy_identifier: 12_345
    visit organization_member_codes_path(organization, member)
    within('.index-table') do
      expect(page).to have_content t('codes.legacy')
    end
  end

  describe 'locking' do
    let(:code) { codes(:logan) }

    it 'has a link to lock the code if it is not locked already' do
      visit organization_member_codes_path(organization, member)
      expect(page).to have_button t('codes.lock')
      Code::LOCK_REASONS.each do |reason|
        expect(page).to have_link t("codes.#{reason}"), href: lock_code_path(code, reason: reason)
      end
    end

    it 'updates the lock status to locking', js: true do
      visit organization_member_codes_path(organization, member)
      click_on t('codes.lock')
      click_on t('codes.lost')
      expect(page).to have_no_button t('codes.lock')
      expect(codes(:logan)).to be_locking
    end

    it 'passes the reason to the card lock method' do
      expect_any_instance_of(Code).to receive(:lock).with 'lost'
      visit organization_member_codes_path(organization, member)
      click_on t('codes.lost')
    end

    %i[locking locked].each do |status|
      it "does not link to locking a code if it is #{status}" do
        code.update status: :locking
        visit organization_member_codes_path(organization, member)
        Code::LOCK_REASONS.each do |reason|
          expect(page).to have_no_link t("codes.#{reason}"), href: lock_code_path(code, reason: reason)
        end
      end
    end
  end

  describe 'usage' do
    let(:code) { codes(:logan) }

    context 'with usage' do
      let(:used_at) { 1.hour.ago }

      let!(:usage) do
        Usage.create(
          code: code,
          amount: 10.to_money,
          external_id: 'ABCD1234',
          used_at: used_at
        )
      end

      it 'expands to show the code usage', js: true do
        visit organization_member_codes_path(organization, code.member)
        expect(page).to have_no_content 'Usage'
        find('td', text: code.code_identifier).click
        expect(page).to have_content 'Usage'
        expect(page).to have_content '$10'
        expect(page).to have_content usage.code_identifier
        expect(page).to have_content l(usage.used_at, format: :mmddyyyy)
      end
    end

    context 'without usage' do
      before { code.usages.destroy_all }

      it 'says the code has no usage', js: true do
        visit organization_member_codes_path(organization, code.member)
        expect(page).to have_no_content 'Usage'
        find('td', text: code.code_identifier).click
        expect(page).to have_content t('usages.table.no_usage')
      end
    end
  end

  describe 'redemption instructions' do
    let!(:code) { codes(:logan) }
    let!(:instruction) { redemption_instructions(:exam) }

    context 'with instructions' do
      before do
        code.product_category.update(redemption_instructions_editable: true)
        instruction.update(active: true)
        visit organization_member_codes_path(organization, code.member)
      end

      it 'expands to show the redemption instruction', js: true do
        expect(page).to have_no_content t('codes.index.redemption_instructions')
        find('td', text: code.code_identifier).click

        expect(page).to have_content t('codes.index.redemption_instructions')
        expect(page).to have_content(instruction.description)
      end
    end

    context 'instructions set for a different organization' do
      let(:admin) { users(:admin) }
      let(:other_organization) { organizations(:bridge) }
      let(:other_member) { members(:angelita) }
      let(:other_code) { codes(:angelita) }

      before do
        sign_in admin
        other_member.update(order: orders(:bridge))
        other_code.product_category.update(redemption_instructions_editable: true)
        instruction.update(active: true)
        visit organization_member_codes_path(other_organization, other_code.member)
      end

      it 'are not seen by current org' do
        expect(page).to have_no_content t('codes.index.redemption_instructions')
        find('td', text: other_code.code_identifier, match: :first).click

        expect(page).to have_no_content t('codes.index.redemption_instructions')
        expect(page).to have_no_content(instruction.description)

        expect(code.redemption_instructions.find_by(active: true, organization: organization)).to eq(instruction)
        expect(other_code.redemption_instructions.find_by(active: true, organization: other_organization)).to be_nil
      end
    end

    context 'without instructions' do
      context 'set for the organization' do
        before do
          code.product_category.update(redemption_instructions_editable: true)
          RedemptionInstruction.destroy_all
        end

        it 'does not show the instruction section', js: true do
          visit organization_member_codes_path(organization, code.member)
          expect(page).to have_no_content t('organization_portal.codes.index.redemption_instructions')

          find('td', text: code.code_identifier).click
          expect(page).to have_no_content t('organization_portal.codes.index.redemption_instructions')
        end
      end

      context 'allowed for the product category' do
        it 'does not show the instruction section', js: true do
          visit organization_member_codes_path(organization, code.member)
          expect(page).to have_no_content t('organization_portal.codes.index.redemption_instructions')

          find('td', text: code.code_identifier).click
          expect(page).to have_no_content t('organization_portal.codes.index.redemption_instructions')
        end
      end
    end
  end

  describe 'product description' do
    let!(:new_code) { codes(:logan) }

    context 'with text' do
      before { new_code.product_category.update(product_description: 'Howdy') }

      it 'expands to show the product description', js: true do
        visit organization_member_codes_path(organization, new_code.member)
        expect(page).to have_no_content t('codes.index.product_description')
        find('td', text: new_code.code_identifier).click

        expect(page).to have_content t('codes.index.product_description')
        expect(page).to have_content(new_code.product_category.product_description)
      end
    end

    context 'without text' do
      before { new_code.product_category.update(product_description: '') }

      it 'expands to show no description message', js: true do
        visit organization_member_codes_path(organization, new_code.member)
        expect(page).to have_no_content t('codes.index.product_description')
        find('td', text: new_code.code_identifier).click

        expect(page).to have_content t('codes.index.product_description')
        expect(page).to have_content t('codes.index.no_product_description')
      end
    end
  end

  describe 'code search' do
    before do
      visit organization_member_codes_path(organization, member)
    end

    context 'has field and buttons for searching' do
      it 'shows a search field and buttons' do
        expect(page).to have_field 'q[product_category_name_or_balance_cents_or_order_id_or_id_or_external_id_cont]'
        expect(page).to have_link t('helpers.search.clear')
        expect(page).to have_link t('helpers.search.advanced')
      end
    end
  end

  describe 'advanced code search' do
    let!(:code1) { codes(:logan) }
    let!(:code2) { member.codes.create! limit: 50.to_money, status: :activated, external_id: :ACTIVATED123, plan_product_category: plan_product_categories(:fashion) }
    let!(:code3) { member.codes.create! limit: 50.to_money, status: :activated, plan_product_category: plan_product_categories(:fashion) }

    before do
      visit organization_member_codes_path(organization, member)
      click_link t('helpers.search.advanced')
    end

    context 'advanced search form' do
      it 'has the search fields/selects' do
        expect(page).to have_field 'q[external_id_cont]'
        expect(page).to have_field 'q[order_id_cont]'
        expect(page).to have_field 'q[created_at_gteq]'
        expect(page).to have_field 'q[created_at_lteq]'
        expect(page).to have_select 'q[status_eq]'
        expect(page).to have_select 'q[product_category_name_eq]'
        expect(page).to have_field 'q[deactivated_at_gteq]'
        expect(page).to have_field 'q[deactivated_at_lteq]'
        expect(page).to have_field 'q[amount_used_gteq]'
        expect(page).to have_field 'q[amount_used_lteq]'
        expect(page).to have_field 'q[balance_gteq]'
        expect(page).to have_field 'q[balance_lteq]'
        expect(page).to have_field 'q[limit_gteq]'
        expect(page).to have_field 'q[limit_lteq]'
        expect(page).to have_button t('helpers.search.apply_filter')
      end
    end

    context 'search for existing codes' do
      it 'searches by external_id' do
        fill_in 'q[external_id_cont]', with: code1.external_id
        apply_filter
        expect(page).to have_content code1.code_identifier
        expect(page).not_to have_content code2.code_identifier
      end

      it 'searches by order ID' do
        fill_in 'q[order_id_cont]', with: code1.order.id.to_s
        apply_filter

        expect(page).to have_content code1.order.id.to_s
        expect(page).to have_content code2.order.id.to_s
      end

      it 'searches by code status' do
        select code1.status, from: 'q[status_eq]'
        apply_filter

        expect(page).to have_content t("codes.statuses.#{code1.status}")
        expect(page).not_to have_content t("codes.statuses.#{code2.status}")
      end

      it 'does not show duplicate code status' do
        expect(page).to have_select('q[status_eq]', options: ['', 'generated', 'activated'])
      end

      it 'searches by product_category' do
        select code1.product_category.name, from: 'q[product_category_name_eq]'
        apply_filter

        expect(page).to have_content code1.product_category.name
        expect(page).not_to have_content code2.product_category.name
      end
    end

    context 'clear search filters' do
      it 'clears the filters on click' do
        fill_in 'q[external_id_cont]', with: code1.external_id
        apply_filter

        expect(page).to have_content code1.code_identifier
        expect(page).not_to have_content code2.code_identifier

        click_link t('helpers.search.clear')

        expect(page).to have_content code1.code_identifier
        expect(page).to have_content code2.code_identifier
      end
    end

    context 'search for purchase dates' do
      before do
        code2.update created_at: code1.created_at - 10.days
      end

      it 'searches with two purchase date' do
        fill_in 'q[created_at_gteq]', with: l(code1.created_at - 1.day, format: :mmddyyyy)
        fill_in 'q[created_at_lteq]', with: l(code1.created_at + 1.day, format: :mmddyyyy)
        apply_filter

        expect(page).to have_content l(code1.created_at, format: :mmddyyyy)
        expect(page).not_to have_content l(code2.created_at, format: :mmddyyyy)
      end

      it 'searches with min purchase date' do
        fill_in 'q[created_at_gteq]', with: l(code1.created_at - 1.day, format: :mmddyyyy)
        apply_filter

        # TODO: should the code detail page show the purchase dates?
        expect(page).to have_content code1.code_identifier
        expect(page).not_to have_content code2.code_identifier
      end

      it 'searches with max purchase date' do
        fill_in 'q[created_at_lteq]', with: l(code1.created_at + 1.day, format: :mmddyyyy)
        apply_filter

        # TODO: should the code detail page show the purchase dates?
        expect(page).to have_content code1.code_identifier
        expect(page).to have_content code2.code_identifier
      end
    end

    context 'search for expiration dates' do
      before do
        code1.update deactivated_at: code1.created_at + 10.days
        code2.update deactivated_at: code1.created_at + 20.days
      end

      it 'searches with two deactivation dates' do
        fill_in 'q[deactivated_at_gteq]', with: l(code1.created_at, format: :mmddyyyy)
        fill_in 'q[deactivated_at_lteq]', with: l(code1.created_at + 19.days, format: :mmddyyyy)
        apply_filter

        expect(page).to have_content code1.code_identifier
        expect(page).not_to have_content code2.code_identifier
      end

      it 'searches with min deactivation date' do
        fill_in 'q[deactivated_at_gteq]', with: l(code1.created_at + 11.days, format: :mmddyyyy)
        apply_filter

        expect(page).to_not have_content code1.code_identifier
        expect(page).to have_content code2.code_identifier
      end

      it 'searches with max deactivation date' do
        fill_in 'q[deactivated_at_lteq]', with: l(code1.created_at + 19.days, format: :mmddyyyy)
        apply_filter

        expect(page).to have_content code1.code_identifier
        expect(page).to_not have_content code2.code_identifier
      end
    end

    context 'search for amount used' do
      before do
        code1.usages.first.delete
        code1.usages.create(amount_cents: 1_500, used_at: Date.current)
        code2.usages.create(amount_cents: 1_000, used_at: Date.current)
        code2.usages.create(amount_cents: 2_000, used_at: Date.current)
      end

      it 'searches with two amount used bounds' do
        fill_in 'q[amount_used_gteq]', with: 10
        fill_in 'q[amount_used_lteq]', with: 20
        apply_filter

        expect(page).to have_content code1.code_identifier
        expect(page).not_to have_content code2.code_identifier
      end

      it 'searches with a min amount used bound' do
        fill_in 'q[amount_used_gteq]', with: 20
        apply_filter

        expect(page).to_not have_content code1.code_identifier
        expect(page).to have_content code2.code_identifier
      end

      it 'searches with a max amount used bound' do
        fill_in 'q[amount_used_lteq]', with: 20
        apply_filter

        expect(page).to have_content code1.code_identifier
        expect(page).to_not have_content code2.code_identifier
      end
    end

    context 'search for balance' do
      it 'searches with two balance bounds' do
        fill_in 'q[balance_gteq]', with: 10
        fill_in 'q[balance_lteq]', with: 100
        apply_filter

        expect(page).to have_content code1.code_identifier
        expect(page).to_not have_content code2.code_identifier
      end

      it 'searches with a min balance bound' do
        fill_in 'q[balance_gteq]', with: 10
        apply_filter

        expect(page).to have_content code1.code_identifier
        expect(page).to_not have_content code2.code_identifier
      end

      it 'searches with a max balance bound' do
        fill_in 'q[balance_lteq]', with: 40
        apply_filter

        expect(page).to_not have_content code1.code_identifier
        expect(page).to have_content code2.code_identifier
      end
    end

    context 'search for amount credited' do
      before do
        code1.update limit: 20
      end

      it 'searches with two limit bounds' do
        fill_in 'q[limit_gteq]', with: 10
        fill_in 'q[limit_lteq]', with: 30
        apply_filter

        expect(page).to have_content code1.code_identifier
        expect(page).to_not have_content code2.code_identifier
      end

      it 'searches with an upper limit bound' do
        fill_in 'q[limit_lteq]', with: 30
        apply_filter

        expect(page).to have_content code1.code_identifier
        expect(page).to_not have_content code2.code_identifier
      end

      it 'searches with a lower limit bound' do
        fill_in 'q[limit_gteq]', with: 10
        apply_filter

        expect(page).to have_content code1.code_identifier
        expect(page).to have_content code2.code_identifier
      end
    end

    context 'search for non-existing codes' do
      it 'returns an empty table' do
        fill_in 'q[external_id_cont]', with: 'foobar'
        apply_filter
        expect(page).to have_content t('codes.index.no_codes')
      end
    end

    context 'browser refresh clears the search filters' do
      before do
        fill_in 'q[external_id_cont]', with: code1.external_id
        apply_filter
      end

      it 'navigates to the codes index, filtered' do
        expect(page.current_path).to eq search_organization_member_code_index_path(organization, member)
        expect(page).not_to have_content code2.code_identifier
      end

      it 'navigates to the codes index, unfiltered' do
        visit current_path
        expect(page.current_path).to eq organization_member_codes_path(organization, member)
        expect(page).to have_content code2.code_identifier
      end
    end
  end

  def apply_filter
    click_button t('helpers.search.apply_filter')
  end
end
