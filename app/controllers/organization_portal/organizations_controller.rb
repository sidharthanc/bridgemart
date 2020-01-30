class OrganizationPortal::OrganizationsController < ::OrganizationPortalController
  def edit
    @organization = OrganizationPortal::Organization.find(current_organization.id)
    @disable_fields = true unless policy(current_organization).edit?
  end

  def update
    @organization = OrganizationPortal::Organization.update_attributes(current_organization.id, permitted_params)
    authorize current_organization
    @organization.save
    respond_with @organization, location: organization_path(current_organization)
  end

  private
    def permitted_params
      params.require(:organization_portal_organization)
            .permit(
              %i[
                contact_first_name
                contact_last_name
                contact_email
                contact_phone
                organization_name
                organization_industry
                organization_number_of_employees
                number_of_employees_with_safety_rx_eyewear
                street1
                street2
                city
                zip
                state
              ]
            )
    end
end
