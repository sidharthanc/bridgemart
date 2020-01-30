describe 'Admin Usage Imports', type: :request do
  let(:index) { AdminPages::Index.new(UsageImport) }

  as { users(:andrew) }
  before { index.visit }

  describe 'New' do
    let(:form) { index.new_form }
    before { index.navigate_to :new }

    it 'should successfully create the record' do
      attach_valid_usage_file

      form.submit

      expect(page).to have_content 'was successfully created'
    end

    context 'without a usage file' do
      it 'should show an appropriate error' do
        form.submit

        expect(page).to have_content 'must be attached'
      end
    end
  end

  def attach_valid_usage_file
    attach_file 'File', file_fixture('walmart-usage.xlsx')
  end
end
