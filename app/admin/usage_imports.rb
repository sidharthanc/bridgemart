ActiveAdmin.register UsageImport do
  permit_params :file

  controller do
    after_action :enqueue_job, only: :create

    def enqueue_job
      Walmart::BatchTransactionHistoryJob.perform_later(resource) if resource.persisted?
    end
  end

  show do
    default_main_content do
      row(:file) { link_to 'File', url_for(usage_import.file) }
    end
  end

  form do |form|
    form.semantic_errors

    form.inputs do
      form.input :file, as: :file
    end

    form.actions
  end
end
