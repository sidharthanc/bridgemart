ActiveAdmin.register PaymentMethod do
  actions :index, :show, :destroy
  preserve_default_filters!
  remove_filter :audits, :updated_at, :deleted_at, :created_at

  controller do
    def destroy
      payment_method = PaymentMethod.find(params.fetch(:id))
      payment_method.destroy
      redirect_to admin_payment_methods_path, notice: I18n.t('active_admin.payment_methods.delete_message')
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_payment_methods_path, notice: I18n.t('active_admin.payment_methods.record_not_exist')
    end
  end

  action_item :destroy, only: :show do
    link_to 'Delete Payment Method', "/admin/payment_methods/#{payment_method.id}", method: :delete
  end

  index do
    id_column
    column :organization
    column :customer_vault_id
    column :ach_account_name
    column :ach_account_token
    column :ach_account_type
    column :credit_card_token
    column :credit_card_expiration_date
    actions
  end

  show do
    attributes_table do
      row(:organization)
      row(:customer_vault_id)
      row(:billing_id)
      row(:ach_account_name)
      row(:ach_account_token)
      row(:ach_account_type)
      row(:credit_card_token)
      row(:credit_card_expiration_date)
      row(:created_at)
      row(:updated_at)
      row(:location_id)
      row(:deleted_at)
    end
    active_admin_comments
  end
end
