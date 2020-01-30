class Usage < ApplicationRecord
  acts_as_paranoid
  belongs_to :code
  has_one :member, through: :code
  monetize :amount_cents, :total_usage_cents, :total_per_visit_cents, :retail_price_cents

  after_commit :update_organization_usage_total_cache

  delegate :code_identifier, to: :code

  def update_organization_usage_total_cache
    code&.organization&.update_usage_total_cache
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << column_headers

      all.each do |usage|
        csv << col_names.map { |attr| usage.send(attr) }
      end
    end
  end

  def order
    code.order.id
  end

  def member
    code.member.id
  end

  def self.column_headers
    col_names.map do |col|
      I18n.t("usages.index.columns.#{col}")
    end
  end

  def self.col_names
    column_names.insert(2, 'order')
    @col_names ||= column_names.deep_dup.map { |colname| colname.gsub!(/_cents/, '') || colname }
    @col_names |= %w[member]
  end

  def code_identifier
    code.legacy_identifier.present? ? code.legacy_identifier : code.id
  end
end
