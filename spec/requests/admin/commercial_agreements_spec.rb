describe 'Admin Commercial Agreements', type: :request do
  let(:index) { AdminPages::Index.new(CommercialAgreement) }

  as { users(:andrew) }
  before { index.visit }

  describe 'New' do
    let(:form) { index.new_form }
    let(:organization) { organizations(:metova) }
    before { index.navigate_to :new }

    it 'should successfully create the record' do
      attach_file('commercial_agreement[pdf]', Rails.root + 'spec/fixtures/files/test.pdf')
      form.submit

      expect(page).to have_content t('flash.actions.create.notice', resource_name: 'Commercial agreement')
    end

    it 'should successfully create record with organization' do
      attach_file('commercial_agreement[pdf]', Rails.root + 'spec/fixtures/files/test.pdf')
      select organization.name
      form.submit

      expect(page).to have_content t('flash.actions.create.notice', resource_name: 'Commercial agreement')
      visit admin_commercial_agreements_path
      expect(page).to have_content organization.name
    end
  end
end
