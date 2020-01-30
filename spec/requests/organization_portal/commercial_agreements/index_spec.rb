describe 'Commercial Agreements index page', type: :request do
  let(:organization) { organizations(:metova) }
  as { users(:joseph) }

  it 'is linked to on the nav bar in the header' do
    visit edit_organization_organization_path(organization)
    expect(page).to have_link I18n.t('layouts.organization_portal.nav.commercial_agreements'), href: organization_commercial_agreements_path(organization)
  end

  context 'show attachments' do
    let(:organization) { organizations(:metova) }
    let(:commercial_agreement) { commercial_agreements(:signed_agreement) }

    let(:signature) { signatures(:master) }
    let(:pdf_attachment) { commercial_agreement.pdf }

    before do
      attachment_path = "#{Rails.root}/spec/fixtures/files/test.pdf"
      pdf_attachment.attach(io: File.open(attachment_path), filename: 'test.pdf')
    end

    it 'shows each agreement filename, and sign date (the date the plan was created)' do
      visit organization_commercial_agreements_path(organization)
      expect(page).to have_link pdf_attachment.filename
      expect(page).to have_content signature.created_at
    end
  end
end
