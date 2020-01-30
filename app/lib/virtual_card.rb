class VirtualCard
  include ActiveModel::Model

  attr_accessor :card_number, :pin, :provider
  attr_accessor :created_at, :expires_at, :closed_at, :registered_at, :locked_at

  validates :balance, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :card_number, presence: true
  validates :pin, presence: true
  validates :provider, presence: true

  def balance
    Money.new(@balance)
  end

  def balance=(value)
    @balance = value.is_a?(Money) ? value.cents : value
  end

  class InvalidProviderError < StandardError; end

  concerning :Providers do
    def provider_service
      provider.safe_constantize.new(self)
    rescue ArgumentError, NoMethodError => e
      raise InvalidProviderError, "Provider: #{provider}"
    end
  end
end
