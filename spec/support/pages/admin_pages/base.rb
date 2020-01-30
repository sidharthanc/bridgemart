module AdminPages
  class Base
    include Capybara::DSL
    include Rails.application.routes.url_helpers

    attr_reader :model

    def initialize(model)
      @model = model
    end

    def click_submit(action)
      click_button action.to_s.capitalize, exact_text: false
    end

    def fill_in_attributes(attributes)
      attributes.each do |key, value|
        fill_in field_name(key), with: value
      end
    end

    def field_name(attribute_name)
      "#{model.model_name.param_key}[#{attribute_name}]"
    end
  end
end
