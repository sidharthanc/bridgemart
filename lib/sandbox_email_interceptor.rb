class SandboxEmailInterceptor
  def self.delivering_email(message)
    Notification.create!(
      sent_to: message.to,
      fields: message["dynamic-template-data"].instance_variable_get(:@unparsed_value),
      template_id: message["template-id"].value
    )
    message.perform_deliveries = false
  end
end
