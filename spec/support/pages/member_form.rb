class MemberForm
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def fill(address: true)
    within container do
      fill_in "#{resource_param_name}[first_name]", with: 'Test'
      fill_in "#{resource_param_name}[last_name]", with: 'Testerson'
      fill_in "#{resource_param_name}[email]", with: 'test@metova.com'
      fill_in "#{resource_param_name}[phone]", with: '(123) 456-7890'
      fill_in "#{address_param_name}[street1]", with: '3301 Aspen Grove Dr' if address
      fill_in "#{address_param_name}[city]", with: 'Franklin' if address
      select 'TN', from: "#{address_param_name}[state]" if address
      fill_in "#{address_param_name}[zip]", with: '37067' if address
    end
  end

  def choose_plan(plan)
    select plan_option_text(plan), from: "#{resource_param_name}[plan_id]"
  end

  def plan_option_text(plan)
    I18n.t 'simple_form.plan_input', starts_on: I18n.l(plan.starts_on, format: :Mddyyyy), ends_on: I18n.l(plan.ends_on, format: :Mddyyyy)
  end

  def submit
    within container do
      find('input[name="commit"]').click
    end
  end

  private
    def resource_param_name
      :member
    end

    def address_param_name
      "#{resource_param_name}[address_attributes]"
    end

    def container
      all('.new_member').any? ? '.new_member' : '.edit_member'
    end
end
