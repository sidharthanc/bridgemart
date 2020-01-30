require 'watir'
require 'webdrivers'
require 'faker'

class Scenario
  attr_reader :attributes, :options, :user
  def initialize(attributes)
    @attributes = attributes
    @options = attributes[:options]
    @user = attributes[:user]
  end

  def configure_and_connect
    @browser = Watir::Browser.new(:chrome, options: { options: { w3c: true } })

    Watir.default_timeout = 90

    @browser.goto 'localhost:3000'
  end

  def log_in
    @browser.text_field(id: "user_email").set @user[:email]

    @browser.text_field(id: "user_password").set @user[:password]

    @browser.input(name: "commit").click
  end

  def link_by_text(string)
    @browser.link(text: string).click
  end

  def link_by_href(string)
    @browser.link(href: string).click
  end

  def link_by_class(string)
    @browser.link(class: string).click
  end

  def kill_bullet_footer
    @browser.div(id: "bullet-footer").double_click
  end

  def close_browser
    @browser.close
  end
end
