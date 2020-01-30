module Ransackable
  extend ActiveSupport::Concern

  def adjust_ransack_date_range_for_attribute(params, attribute)
    return unless params[:q]

    min_default_date = params.dig(:q, "#{attribute}_lteq").blank? ? nil : 100.years.ago
    max_default_date = params.dig(:q, "#{attribute}_gteq").blank? ? nil : 100.years.from_now
    min_date = normalize_date(params[:q].delete("#{attribute}_gteq"), min_default_date)
    max_date = normalize_date(params[:q].delete("#{attribute}_lteq"), max_default_date)
    params[:q]["#{attribute}_between"] = "#{min_date},#{max_date}" unless min_date.nil? || max_date.nil?
  end

  def normalize_date(date, default_date)
    return default_date if date.blank?

    Date.strptime(date, '%m/%d/%Y')
  end
end
