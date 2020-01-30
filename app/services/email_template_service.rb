require 'sendgrid-ruby'

class EmailTemplateService
  include SendGrid

  def self.compile_template(path)
    string = File.read(path)
    compile(string)
  end

  def self.compile(template_string)
    ActionController::Base.new.render_to_string inline: template_string, type: :mjml
  end

  def self.plain_content(html_content)
    ActionController::Base.helpers.strip_tags(html_content).delete!("\n").gsub(/ +/, " ")
  end

  def self.create_template_version(template_id:, html_content:, plain_content:, name: SecureRandom.hex, subject:)
    data = {
      'active': 1,
      'html_content': html_content,
      'name': name,
      'plain_content': plain_content,
      'subject': subject,
      'template_id': template_id
    }
    sendgrid_api.client.templates._(template_id).versions.post(request_body: data)
  end

  def self.sendgrid_api
    SendGrid::API.new(api_key: sendgrid_api_key)
  end

  def self.sendgrid_api_key
    Rails.application.credentials.dig :sendgrid, :api_key_endpoints
  end
end
