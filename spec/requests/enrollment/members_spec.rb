describe 'Members page', type: :request do
  let(:order) { orders(:metova) }
  as { users(:joseph) }

  describe 'navigation' do
    it 'goes back to the product detail page' do
      visit new_enrollment_order_member_path order
      expect(page).to have_link I18n.t('enrollment.back'), href: edit_enrollment_order_path(order), count: 1
    end
  end
end
