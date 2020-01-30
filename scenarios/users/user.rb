require 'watir'
require 'webdrivers'
require 'faker'
require 'byebug'
require '../scenarios.rb'

# require 'factory_bot'
# require '../../spec/factories/user'
# FactoryBot.find_definitions
# Tests are not implemented into the rest of the application, so using FactoryBot is currently impossible.

class User < Scenario
  attr_reader :user_sign_up
  def initialize(attributes)
    super
    @user_sign_up = attributes[:user_sign_up]
  end

  # def default_user_attributes
  #   FactoryBot.attributes_for(:user)
  # end

  # def member_strategy
  #   options[:member_strategy] || :manual
  # end

  def sign_up_new_user
    @browser.text_field(id: 'sign_up_first_name').set @user_sign_up[:first_name]

    @browser.text_field(id: 'sign_up_last_name').set @user_sign_up[:last_name]

    @browser.text_field(id: 'sign_up_email').set @user_sign_up[:email]

    @browser.text_field(id: 'sign_up_organization_name').set Faker::Company.name + ' ' + Faker::Company.suffix

    @browser.select_list(id: 'sign_up_industry').select "Auto"

    @browser.scroll.to :bottom

    # Cannot tell if this line is broken or if it's just the general inconsistency of this scenario.
    @browser.label(for: "sign_up_product_category_ids_" + rand(3).to_s).click

    @browser.button(name: "commit").click
  end

  def set_order_value
    @browser.text_field(id: "order_plan_product_categories_attributes_0_budget").set 15

    @browser.button(name: "commit").click
  end

  def create_new_member
    @browser.text_field(id: "member_first_name").set Faker::Name.first_name

    @browser.text_field(id: "member_last_name").set Faker::Name.last_name

    @browser.text_field(id: 'member_email').set Faker::Internet.email

    @browser.button(name: "commit").click
  end

  def create_members(member_strategy)
    create_new_member
    member_strategy.times do
      link_by_text "Add Member"
      create_new_member
    end
  end

  def enter_billing_information
    @browser.iframe(src: "https://fts.cardconnect.com:6443/itoke/ajax-tokenizer.html?tokenpropname=ccToken&enhancedresponse=true&formatinput=true&unique=true&css=body{margin:0;padding:0;}input{border:1px%20solid%20%23ced4da;border-radius:4px;padding:0.375em%200.75em;font-size:16px;color:%23495057;line-height:1.5;}input%3Afocus{border-color:%2338f087;box-shadow:0%200%200%200.2em%20rgba(12,%20156,%2074,%200.25);}input%2Eerror{border-color:red;}").text_field(id: "ccnumfield").set "4111111111111111"

    @browser.text_field(id: "payment_credit_card_expiration_date").set "5/22"

    @browser.text_field(id: "payment_credit_card_cvv").set "123"

    @browser.text_field(id: "payment_street1").set Faker::Address.street_address

    @browser.scroll.to :bottom

    @browser.text_field(id: "payment_city").set Faker::Address.city

    @browser.select_list(id: "payment_state").select "CA"

    @browser.text_field(id: "payment_zip").set "92081"

    @browser.span(class: "click-text").click

    @browser.scroll.to :bottom

    @browser.button(text: "Accept").click

    @browser.footer(class: "modal-footer").wait_while(&:present?)

    @browser.scroll.to :bottom

    @browser.input(name: "commit").when_present(15_000).click
  end

  def sign_up
    configure_and_connect
    link_by_text "Sign Up"
    sign_up_new_user
    set_order_value
    create_members @options[:member_strategy]
    link_by_class "btn btn-wide btn-primary"
    enter_billing_information
    close_browser
  end

  def view_members_and_codes
    configure_and_connect
    log_in
    link_by_text "Members"
    link_by_text "Codes"
    close_browser
  end
end

attributes = Hash.new("attributes")
attributes = { user_sign_up: { email: Faker::Internet.email, first_name: 'Dummy', last_name: 'User', password: 'password' }, user: { email: "dakota@ross.solutions", password: "password" }, options: { member_strategy: 3 } }

user = User.new(attributes)

# Navigates to user sign up page, enters necessary information, selects Bridge product plan, adds a number of members(defined by member_strategy), enters payment information.
# user.sign_up
###########################################

# Logs in as user, views members and codes for user's organization.
# user.view_members_and_codes
###########################################
