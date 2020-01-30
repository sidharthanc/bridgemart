ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    div class: 'blank_slate_container', id: 'dashboard_default_message' do
      span class: 'blank_slate' do
        link_to I18n.t('admin.organizations'), organizations_path
      end
    end

    # Service activity is a little bit broken, and very slow.
    # A more comprehensive solution is coming soon™  # rubocop:disable Style/AsciiComments
    # panel I18n.t('admin.service_activity.label') do
    #   activity = Rails.cache.fetch('service-activity-statistics', expires_in: 1.hour) do
    #     ServiceActivity.recent_statistics
    #   end

    #   activity.each_pair do |service, entries|
    #     div do
    #       render partial: "service_activity", locals: { service: service, entries: entries }
    #     end
    #   end
    # end
  end
end
