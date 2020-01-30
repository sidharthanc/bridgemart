describe 'Admin Audit Logs', type: :request do
  let(:index) { AdminPages::Index.new('audit_logs') }
  let(:user) { users(:andrew) }

  as { user }
  before { index.visit }

  describe 'allowed actions' do
    it 'should show the view link' do
      expect(page).to have_link 'View'
    end

    it 'should not show the edit link' do
      expect(page).not_to have_link 'Edit'
    end

    it 'should not show the delete link' do
      expect(page).not_to have_link 'Delete'
    end
  end

  describe 'Index' do
    it 'should show the records' do
      expect(page).to have_content 'Auditable'
      expect(page).to have_content 'Auditable Type'
      expect(page).to have_content 'Action'
      expect(page).to have_content 'Audited Changes'
      expect(page).to have_content 'Created At'

      within '#index_table_audit_logs' do
        expect(page).to have_content user.full_name
        expect(page).to have_content 'update'
      end
    end
  end

  describe 'Show' do
    before { index.navigate_to :view }

    it 'should show the record' do
      expect(page).to have_content 'Auditable'
      expect(page).to have_content 'Auditable Type'
      expect(page).to have_content 'Action'
      expect(page).to have_content 'Audited Changes'
      expect(page).to have_content 'Created At'

      within '#main_content' do
        expect(page).to have_content user.full_name
        expect(page).to have_content 'update'
      end
    end
  end
end
