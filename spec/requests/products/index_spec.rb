describe 'Plans index page', type: :request do
  as { users(:joseph) }
  let(:user) { users(:joseph) }
  let(:organization) { organizations(:metova) }

  it 'displays a card for each product category in the users plans' do
    visit organization_plans_path(organization)

    user.plans.each do |plan|
      plan.plan_product_categories do |plan_product_category|
        expect(page).to have_content plan_product_category.name
        expect(page).to have_content plan_product_category.budget.format(:no_cents_if_whole)
        expect(page).to have_content I18n.l(plan_product_category.ends_on, format: :mmddyyyy)
      end
    end
  end
end
