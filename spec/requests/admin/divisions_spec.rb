describe 'Admin Divisions', type: :request do
  let(:index) { AdminPages::Index.new(Division) }
  let(:user) { users(:andrew) }

  as { user }
  before { index.visit }

  describe 'Show' do
    before { index.show divisions(:bridge_vision) }

    it 'should show details' do
      expect(page).to have_content divisions(:bridge_vision).name
    end
  end
end
