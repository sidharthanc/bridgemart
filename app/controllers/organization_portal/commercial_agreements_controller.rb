class OrganizationPortal::CommercialAgreementsController < OrganizationPortalController
  def index
    @search = current_organization.signatures.ransack(params[:q])
    @search.sorts ||= ['created_at desc']
    @pagy, @signatures = paginate @search.result
  end
end
