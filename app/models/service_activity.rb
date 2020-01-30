class ServiceActivity < ApplicationRecord
  serialize :exception
  serialize :metadata

  scope :created_since, ->(time) { where("service_activities.created_at > ?", time) if time.present? }
  scope :successful, -> { where.not(successful_at: nil) }
  scope :failures, -> { where.not(failure_at: nil) }

  def self.recent_statistics(depth = 5)
    query = <<~SQL
      SELECT recent_activity.* FROM (
        SELECT service_activities.*,
        rank() OVER (
            PARTITION BY (service, action)
            ORDER BY created_at DESC
        )
        FROM service_activities
      ) recent_activity WHERE RANK <= #{depth}
    SQL
    find_by_sql(query).group_by(&:service)
  end

  def self.record(service, action)
    service_activity = create(service: service, action: action)
    begin
      return_value = yield(service_activity) if block_given?
    rescue StandardError => e
      service_activity.failure(e)
      raise e
    else
      service_activity.success('OK') unless service_activity.message.present?
    end
    return_value
  end

  def success_or_failure
    successful_at.present? ? "success" : "failure"
  end

  def success(msg = "OK")
    if msg
      update(successful_at: Time.current, message: msg)
    else
      touch(:successful_at)
    end
  end

  def failure(exception_or_msg)
    if exception_or_msg.is_a? StandardError
      update(failure_at: Time.current, exception: exception_to_hash(exception_or_msg))
    else
      update(failure_at: Time.current, message: exception_or_msg)
    end
  end

  private

    def exception_to_hash(exp)
      return {} unless exp.present?

      {
        class: exp.class,
        backtrace: exp.backtrace,
        message: exp.message
      }
    end
end
