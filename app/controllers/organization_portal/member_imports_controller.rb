module OrganizationPortal
  class MemberImportsController < ApplicationController
    before_action :find_organization

    def index
      @member_imports = @organization.member_imports.unacknowledged.to_a.keep_if(&:problems?)
      redirect_to organization_members_path(@organization) if @member_imports.empty?
    end

    def clear
      @member_import = MemberImport.find(params[:member_import_id])
      @member_import.acknowledge!
      redirect_to action: :index
    end

    private
      def find_organization
        @organization = ::Organization.find(params[:organization_id])
      end
  end
end
