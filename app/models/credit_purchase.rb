class CreditPurchase < ApplicationRecord
  acts_as_paranoid
  audited

  belongs_to :organization
  belongs_to :payment_method

  has_many :credits, as: :source

  monetize :amount_cents

  validates :amount_cents, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validate :cannot_void_paid

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << column_headers

      all.each do |credit_purchase|
        csv << col_names.map { |attr| credit_purchase.send(attr) }
      end
    end
  end

  def self.column_headers
    col_names.map do |col|
      I18n.t("credit_purchases.index.columns.#{col}")
    end
  end

  def self.col_names
    @col_names ||= column_names.deep_dup.map { |colname| colname.gsub!(/_cents/, '') || colname }
  end

  def paid?
    paid_at?
  end

  def voided?
    voided_at?
  end

  def void!
    update voided_at: DateTime.now
  end

  def paid!
    update error_message: nil, paid_at: DateTime.now
  end

  def status
    return :void if voided?
    return :paid if paid?

    :none
  end

  def editable?
    !(voided? || paid?)
  end

  def voidable?
    !(voided? || paid?)
  end

  def payable?
    !(voided? || paid?)
  end

  private
    def cannot_void_paid
      errors.add :voided_at, :cannot_void if voided? && paid?
    end
end
