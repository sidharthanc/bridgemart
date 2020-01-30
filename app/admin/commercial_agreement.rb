ActiveAdmin.register CommercialAgreement do
  actions :all
  permit_params :pdf, :organization_id
  remove_filter :audits

  form partial: 'form'

  index do
    column :id
    column :organization
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :pdf do |agreement|
        tag :embed, src: url_for(agreement.pdf), class: 'commercial-agreement' if agreement.pdf.attached?
      end
    end
  end
end
