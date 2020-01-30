# spec/support/wait_for_ajax.rb
module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    still_active = page.evaluate_script('jQuery.active')
    still_active.nil? || still_active.zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax
end
