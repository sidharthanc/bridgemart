RSpec.describe EmailTemplateService do
  describe 'mjml' do
    html_content = EmailTemplateService.compile_template(Rails.root.join('spec/fixtures/files/example.mjml'))

    it 'is compiled to html' do
      expect(html_content).to include('<!doctype html>')
    end

    it 'converts html string to plain content' do
      plain_content = EmailTemplateService.plain_content(html_content)
      expect(plain_content).to be_a String
    end
  end

  describe '.create_template_version', vcr: { cassette_name: 'create_template_version' } do
    html_content = EmailTemplateService.compile_template(Rails.root.join('spec/fixtures/files/example.mjml'))
    plain_content = EmailTemplateService.plain_content(html_content)

    it 'makes a http requests' do
      EmailTemplateService.create_template_version(template_id: 'd-76481a7c3fe743d0aad0f7f409eedcb6', subject: "random subject 2", html_content: html_content, plain_content: plain_content)
    end
  end
end
