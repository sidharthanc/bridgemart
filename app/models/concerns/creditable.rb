module Creditable
  extend ActiveSupport::Concern

  included do
    has_many :credits
  end

  def credit_pool(amount:, source: nil)
    credits << Credit.new(amount: amount, source: source)
  end

  def credit_total
    Rails.cache.fetch("#{model_name.plural}/#{cache_key}/calculated/credit_total") do
      sum_monetized(credits, :amount)
    end
  end

  def remaining_balance_at(credit)
    # the clause is looking at just the credits _before_ the given one for its totals
    sum_monetized(credits.where("created_at <= ?", credit.created_at), :amount)
  end
end
