class Credit < ApplicationRecord
  acts_as_paranoid
  audited

  belongs_to :organization
  belongs_to :source, polymorphic: true, optional: true

  after_commit :update_organization_credit_cache

  monetize :amount_cents
  ransack_alias :credit, :source_of_Code_type_external_id

  # Fetches the Legacy Identifier for a particular Credit
  def legacy_identifier
    source.respond_to?(:legacy_identifier) ? source.legacy_identifier : nil
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << column_headers

      find_each do |credit|
        csv << col_names.map { |attr| credit.send(attr) }
      end
    end
  end

  def self.column_headers
    col_names.map do |col|
      I18n.t("credits.index.columns.#{col}")
    end
  end

  def self.col_names
    @col_names ||= column_names.deep_dup.map { |colname| colname.gsub!(/_cents/, '') || colname }
  end

  def type
   return :added if amount > 0
   return :cancelled if source.nil?
   :used
  end

  def update_organization_credit_cache
    organization.update_credit_cache
  end

  def cancel
    update(source: nil)
    organization.credit_pool(amount: -self.amount)
  end

  def cancelable?
    source.present? && amount.positive? && organization.credit_total_cached >= amount
  end
end
