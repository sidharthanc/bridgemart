describe 'Importing members via CSV', type: :request, js: true do
  let(:csv) { fixture_file_upload('files/members.csv') }
  let(:invalid_csv) { fixture_file_upload('files/members.invalid.csv') }
  let(:order) { orders(:metova) }
  as { order.primary_user }

  before { visit new_enrollment_order_member_path(order, mode: :csv) }

  it 'shows a CSV dropzone by default' do
    expect(page).to have_css '.dropzone-form'
    expect(page).to have_no_field 'enrollment_member[first_name]'
  end

  it 'can toggle to the CSV dropzone' do
    expect(page).to have_css '.dropzone-form'
    click_on I18n.t('enrollment.members.mode_choice.manual.title')
    expect(page).to have_no_css '.dropzone-form'
    click_on I18n.t('enrollment.members.mode_choice.csv.title')
    expect(page).to have_css '.dropzone-form'
  end

  it 'shows the member count' do
    drop_file csv.path
    expect(page).to have_content 'All members can be uploaded successfully'
    expect(page).to have_content 'Plus 15 more rows'
  end

  it 'parses and shows the first 5 users' do
    drop_file csv.path
    expect(page).to have_content 'test@metova.com', count: 5
    expect(page).to have_content 'Testerson', count: 5
    1.upto(5) { |n| expect(page).to have_content "30#{n} Aspen Grove Drive" }
  end

  it 'ignores blank lines' do
    file = Tempfile.open do |f|
      headers = File.open(csv.path, &:readline)
      f.write headers + "\n"
      f.write "Test,T,Testerson,test@metova.com,301 Aspen Grove Drive,Franklin,TN,37067\n"
      f.write "\n"
      f.write 'Test,T,Testerson,test@metova.com,301 Aspen Grove Drive,Franklin,TN,37067'
      f
    end

    drop_file file.path
    expect(page).to have_content 'Only 2 out of 3 member(s) can be uploaded successfully'
  end

  describe 'canceling an upload' do
    it 'allows the user to choose another file' do
      drop_file csv.path
      expect(page).to have_no_content 'Drag a .csv file'
      find('.close-btn').click
      expect(page).to have_content 'Drag a .csv file'
    end

    it 'resets the members when choosing a file after canceling' do
      drop_file csv.path
      expect(page).to have_no_content 'Drag a .csv file'
      find('.close-btn').click
      expect(page).to have_content 'Drag a .csv file'
      drop_file csv.path
      expect(page).to have_content 'All members can be uploaded successfully'
    end
  end

  describe 'viewing template' do
    let(:template) { 'FirstName,MiddleName,LastName,Email,Street,City,State,Zip' }

    it 'can display the template inline' do
      click_on 'View Template'
      expect(page).to have_content template
    end

    it 'can hide the inline template after showing it' do
      click_on 'View Template'
      expect(page).to have_content template
      click_on 'View Template'
      expect(page).to have_no_content template
    end
  end

  describe 'uploading the file' do
    context 'successfully' do
      it 'shows the Uploading... button when the file upload is in progress' do
        allow_any_instance_of(MemberImport).to receive(:start_import) do |member_import|
          Enrollment::MemberImportJob.perform_now member_import
        end

        drop_file csv.path
        click_on 'Upload Members'
        expect(page).to have_content 'Uploading...'
        expect(page).to have_css '.member-container'
        within '.member-container' do
          expect(page).to have_content 'All members can be uploaded successfully'
        end
        expect(page).to have_no_css '.dropzone-form'
        expect(page).to have_no_css '.error-container'
        wait_for_ajax
        expect(page).to have_content t('enrollment.members.csv.complete')
      end

      it 'shows the "Complete" button after successful upload' do
        allow_any_instance_of(MemberImport).to receive(:start_import) do |member_import|
          Enrollment::MemberImportJob.perform_now member_import
        end

        drop_file csv.path
        click_on 'Upload Members'
        expect(page).to have_no_button 'Uploading...'
        expect(page).to have_css '.member-container'
        within '.member-container' do
          expect(page).to have_content 'All members can be uploaded successfully'
        end
        expect(page).to have_no_css '.error-container'
        wait_for_ajax
        expect(page).to have_link I18n.t('enrollment.members.csv.complete')
      end

      it 'enqueues a job to create the records' do
        drop_file csv.path
        expect do
          click_on 'Upload Members'
          page.has_link? I18n.t('enrollment.members.new.complete')
        end.to have_enqueued_job(Enrollment::MemberImportJob).with(MemberImport.last)
      end
    end

    context 'with errors' do
      it 'shows the error messages for each row' do
        drop_file invalid_csv.path
        expect do
          expect(page).to have_content('Only 3 out of 4 member(s) can be uploaded successfully')
          click_on 'Upload Members'
          page.has_link? I18n.t('enrollment.members.new.complete')
        end.to have_enqueued_job(Enrollment::MemberImportJob).with(MemberImport.last)
        Enrollment::MemberImportJob.perform_now MemberImport.last

        within '.error-container' do
          expect(page).to have_content('There were errors, please retry the upload.')
          MemberImport.last.tap do |import|
            import.problems.each do |problem|
              expect(page).to have_content("Row #{problem['index'] + 1}: #{problem['errors'].join(', ')}")
            end
          end
        end
      end
    end
  end
end
