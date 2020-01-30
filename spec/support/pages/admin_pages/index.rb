require_relative 'base'

module AdminPages
  class Index < Base
    def initialize(model, parent: nil)
      super model
      @parent = parent
    end

    def visit
      super polymorphic_path([:admin, *@parent, model])
    end

    def edit_form
      Edit.new(model)
    end

    def new_form
      New.new(model)
    end

    def navigate_to(action)
      click_on(action.to_s.capitalize, match: :first, exact_text: false)
    end

    def show(record = nil, id: record.id)
      click_link(id.to_s)
    end
  end
end
