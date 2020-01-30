class LocationForm
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def fill
    fill_in "#{resource_param_name}[name]", with: 'Test Location'
    fill_in "#{resource_param_name}[contact_name]", with: 'Test Testerson'
    fill_in "#{resource_param_name}[email]", with: 'test@metova.com'
  end

  def fill_additional_info
    fill_in "#{address_param_name}[street1]", with: '123 Location Rd'
    fill_in "#{address_param_name}[city]", with: 'Franklin'
    select 'TN', from: "#{address_param_name}[state]"
    fill_in "#{address_param_name}[zip]", with: '37067'
  end

  def submit
    find('input[name="commit"]').click
  end

  private
    def resource_param_name
      :location
    end

    def address_param_name
      "#{resource_param_name}[address_attributes]"
    end
end
