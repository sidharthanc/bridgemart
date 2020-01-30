describe 'Edit members after manually adding them during enrollment', type: :request do
  let(:form) { MemberForm.new }
  let(:order) { orders(:metova) }
  let(:member) { members(:logan) }
  as { users(:joseph) }

  before { visit edit_enrollment_order_member_path(order, member, mode: :manual) }

  context 'success' do
    it 'has the proper header' do
      expect(page).to have_content I18n.t('enrollment.members.form.legend.edit_member')
    end

    it 'updates the member in the database' do
      fill_in 'member[first_name]', with: 'Test'
      fill_in 'member[middle_name]', with: 'Testerino'
      fill_in 'member[last_name]', with: 'Testerson'
      form.submit
      expect(page).to have_content 'Testerson, Test T.'
      member.reload
      expect(member.first_name).to eq 'Test'
      expect(member.last_name).to eq 'Testerson'
    end

    it "doesn't show the middle initial on the sidebar if they didn't enter one" do
      fill_in 'member[first_name]', with: 'Test'
      fill_in 'member[middle_name]', with: ''
      fill_in 'member[last_name]', with: 'Testerson'
      form.submit
      expect(page).to have_content 'Testerson, Test'
    end

    it 'updates the members address in the database' do
      fill_in 'member[last_name]', with: 'Testerson'
      fill_in 'member[address_attributes][city]', with: 'Franklin'
      select 'TN', from: 'member[address_attributes][state]'
      form.submit
      address = member.reload.address
      expect(address.city).to eq 'Franklin'
      expect(address.state).to eq 'TN'
    end

    it 'links to the edit page after adding a member' do
      visit new_enrollment_order_member_path(order, mode: :manual, add_member: true)
      form.fill
      form.submit
      within '#member-list' do
        expect(page).to have_link 'Edit', href: edit_enrollment_order_member_path(order, Member.last, mode: :manual, anchor: 'member-form')
      end
    end

    it 'updates the sidebar if the first/last name were changed' do
      visit new_enrollment_order_member_path(order, mode: :manual, add_member: true)
      form.fill
      form.submit
      within('#member-list') { click_on 'Edit' }
      expect(page).to have_field 'member[first_name]', with: 'Test'
      fill_in 'member[first_name]', with: 'Tset'
      form.submit
      within '#member-list' do
        expect(page).to have_content 'Testerson, Tset'
      end
    end

    it 'displays the proper button text' do
      expect(page).to have_button 'Save Member'
    end
  end

  context 'failure' do
    it 'shows the errors on the form' do
      fill_in 'member[first_name]', with: ''
      expect do
        form.submit
        expect(page).to have_content "can't be blank"
      end.to_not change {
        member.reload.attributes
      }
    end

    it 'does not update the sidebar' do
      visit new_enrollment_order_member_path(order, member, mode: :manual, add_member: true)
      form.fill
      form.submit

      visit edit_enrollment_order_member_path(order, Member.last, mode: :manual)
      fill_in 'member[first_name]', with: ''
      form.submit

      expect(page).to have_content "can't be blank"
      within '#member-list' do
        expect(page).to have_content 'Testerson, Test'
      end
    end

    it 'does not create any new records' do
      fill_in 'member[first_name]', with: ''
      expect do
        form.submit
        page.has_content? "can't be blank"
      end.to_not change(Member, :count)
    end
  end
end
