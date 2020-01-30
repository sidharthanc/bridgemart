class UserForm
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def fill
    fill_in "#{resource_param_name}[first_name]", with: 'Test'
    fill_in "#{resource_param_name}[last_name]", with: 'Testerson'
    fill_in "#{resource_param_name}[email]", with: email
    fill_in "#{resource_param_name}[phone_number]", with: '(123) 456-7890'
  end

  def submit
    find('input[name="commit"]').click
  end

  def email
    'newemail@metova.com'
  end

  private
    def resource_param_name
      :user
    end
end
