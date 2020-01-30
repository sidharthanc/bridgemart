module Organizations
  class DeleteOrganizationJob < ApplicationJob
    def perform(organization)
      organization.destroy
    end
  end
end
