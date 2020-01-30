describe 'Member Imports Issues index page', type: :request do
  let(:user) { users(:joseph) }
  let(:organization) { organizations(:metova) }

  before do
    sign_in user
  end

  context 'Good Member Import' do
    before do
      import_good_csv
      visit root_path
    end

    it 'does not show a warning symbol on the member link' do
      within(member_link_selector) do
        expect(page).to have_no_css('.fa-exclamation-triangle')
      end
    end

    it 'does not have a link to the Member Import Review screen' do
      visit organization_members_path(organization)
      expect(page).to have_no_link t('members.index.member_import_errors')
      expect(page).to have_no_content t('organization_portal.member_import_errors.index.header')
    end
  end

  context 'Bad Member Import' do
    before do
      import_malformed_csv
      visit root_path
    end

    it 'shows a warning symbol on the member link' do
      within(member_link_selector) do
        expect(page).to have_css('.fa-exclamation-triangle')
      end
    end

    it 'shows a link to the Member Import Review screen' do
      visit organization_members_path(organization)
      expect(page).to have_content t('members.index.member_import_errors')
      click_link t('members.index.member_import_errors')
      expect(page).to have_content t('organization_portal.member_imports.index.header')
    end

    it 'shows the import issue' do
      visit organization_member_imports_path(organization)
      expect(page).to have_content "Row 2: Last name can't be blank"
      expect(page).to have_content 'Row 4: Email is invalid'
    end

    it 'shows the clear button' do
      visit organization_member_imports_path(organization)
      expect(page).to have_css '.btn-info'
      expect(page).to have_link t('organization_portal.member_imports.member_import.action.clear')
    end

    it 'clears the import warning' do
      member_import = MemberImport.last

      expect(member_import.acknowledged).to be false
      visit organization_member_imports_path(organization)
      click_link t('organization_portal.member_imports.member_import.action.clear')
      expect(member_import.reload.acknowledged).to be true
    end
  end

  private
    def import_good_csv
      csv = fixture_file_upload('files/members.csv')
      member_import = MemberImport.create file: csv, order: orders(:metova)
      Enrollment::MemberImportJob.new.perform member_import
    end

    def import_malformed_csv
      csv = fixture_file_upload('files/members.invalid.csv')
      member_import = MemberImport.create file: csv, order: orders(:metova)
      Enrollment::MemberImportJob.new.perform member_import
    end

    def member_link_selector
      ".dashboard-nav a[href='#{organization_members_path(organization)}']"
    end
end
