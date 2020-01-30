describe 'Plans', type: :request do
  let(:plan) { plans(:metova) }
  as { users(:joseph) }

  describe 'view plan information button' do
    context 'before a plan is started' do
      it 'should not result in a fatal error when a plan does not have a starting date' do
        plan.orders.last.update ends_on: nil
        expect { visit organization_plans_path(organizations(:metova)) }.to_not raise_error
      end
    end
  end
end
