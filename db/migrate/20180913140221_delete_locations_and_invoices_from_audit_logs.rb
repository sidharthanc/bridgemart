class DeleteLocationsAndInvoicesFromAuditLogs < ActiveRecord::Migration[5.2]
  def up
    # location_invoice_audit_logs.delete_all

    # confirm_deletion
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Location and Invoice audit logs are not viable in this codebase'
  end

  def confirm_deletion
    raise 'Migration failed to remove Location/Invoice from the audit logs' if location_invoice_audit_logs.exists?
  end

  def audit_logs
    Audited.audit_class
  end

  def location_invoice_audit_logs
    audit_logs.where(auditable_type: 'Location').or(audit_logs.where(auditable_type: 'Invoice'))
  end
end
