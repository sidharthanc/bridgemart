require 'watir'
require 'webdrivers'
require 'faker'
require '../scenarios.rb'

class Admin < Scenario
  def initialize(attributes)
    super
  end

  def go_through_all_pages
    link = @browser.link(text: "Next ›")
    if link.exists?
      link.click
      @browser.refresh
      kill_bullet_footer
      go_through_all_pages
    else
      close_browser
    end
  end

  def select_an_organization
    # Not currently random due to bullet-footer issue.
    # Replace @organizations[0] with @organizations[rand(@organizations.length-1)] when fixed.
    @organizations = []
    @browser.links.each do |link|
      @organizations << link.text if link.id == "organization"
    end
    @browser.link(text: @organizations[0]).click
  end

  def create_user_bridge_admin
    @email = Faker::Internet.email

    @browser.text_field(id: "user_first_name").set Faker::Name.first_name

    @browser.text_field(id: "user_last_name").set Faker::Name.last_name

    @browser.text_field(id: "user_email").set @email

    @browser.text_field(id: "user_password").set "password"

    @browser.text_field(id: "user_password_confirmation").set "password"

    @browser.span(class: "selection").click

    @browser.select_list(id: "user_organization_ids").select "1"

    @browser.select_list(id: "user_permission_group_ids").select "3"

    @browser.scroll.to :bottom

    @browser.li(id: "user_submit_action").click
  end

  def print_credentials
    puts "***New Bridge Admin Credentials***"
    puts "Email: " + @email
    puts "Password: " + "password"
  end

  # *** These are the actual scenarios *** #

  def create_bridge_admin
    configure_and_connect
    log_in
    link_by_href "/admin"
    link_by_href "/admin/users"
    link_by_href "/admin/users/new"
    create_user_bridge_admin
    print_credentials
    close_browser
  end

  def view_members_and_codes
    @organizations = []
    configure_and_connect
    log_in
    select_an_organization
    link_by_text "Members"
    # Hang up in app here, refreshing allows Watir to reach Members page. Can be removed when hang up is fixed.
    @browser.refresh
    link_by_text "Codes"
    close_browser
  end

  def view_all_organizations
    configure_and_connect
    log_in
    kill_bullet_footer
    go_through_all_pages
  end
end

attributes = Hash.new("attributes")
attributes = { user: { email: "admin@bridge-vision.com", password: "password" }, options: {} }

admin = Admin.new(attributes)

# Logs in as admin user, navigates to Active Admin, to Users, to Create New User, enters information into form, setting new user as a new Bridger Admin.
# admin.create_bridge_admin
###########################################

# Logs in as admin user, selects an organization on the first page at random, views organization's members and codes.
# admin.view_members_and_codes
###########################################

# Logs in as admin user, navigates through all pages of organizations.
# admin.view_all_organizations
###########################################
