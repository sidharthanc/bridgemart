class RedemptionInstructionForm
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def fill
    fill_in "#{resource_param_name}[title]", with: 'Title'
    fill_in "#{resource_param_name}[description]", with: 'Description'
  end

  def submit
    find('input[name="commit"]').click
  end

  private
    def resource_param_name
      :redemption_instruction
    end
end
