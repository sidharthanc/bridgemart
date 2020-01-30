# This is essentially the 'backend' of the mocky service that is the masquerading as a 
# remote 'NyanCash' service
module NyanCash
  class Card < ::ApplicationRecord
    self.table_name = "nyan_cash_cards"

    attribute :card_number, :string, default: -> { Faker::Number.unique.number(16) }
    attribute :pin, :string, default: -> { Faker::Number.number(4) }
    attribute :expires_at, :datetime, default: -> { 1.year.from_now }
    attribute :locked_at, :datetime
    attribute :closed_at, :datetime
    attribute :initial_balance, :integer
    attribute :current_balance, :integer

    before_validation on: :create do
      self.current_balance ||= initial_balance
      self.card_number = Faker::Number.unique.number(16) while self.class.exists?(card_number: card_number)
    end

    validates :card_number, :pin, :initial_balance, :current_balance, presence: true
    validates :card_number, uniqueness: true
    validates :initial_balance, presence: true, inclusion: { in: 5_00..1_000_00 }
  
  end

  # For a 'normal' provider this class would likely be much more involved, tested,
  # and potentially even split out into it's own gem
  # Since we are faking this being a remote service, the code in here is not a great
  # example of a service since we can't directly manipulate FirstData/EML codes as
  # an example.
  class Service
    def activate(initial_balance_in_cents)
      record = NyanCash::Card.create(initial_balance: initial_balance_in_cents)
      render(record.attributes)
    end

    def lock(virtual_card)
      record = NyanCash::Card.find_by!(card_number: virtual_card.card_number)
      record.touch(:locked_at)
      render(record.reload.attributes)
    end

    def unlock(virtual_card)
      record = NyanCash::Card.find_by!(card_number: virtual_card.card_number)
      record.update(locked_at: nil)
      render(record.reload.attributes)
    end

    def close(virtual_card)
      record = NyanCash::Card.find_by!(card_number: virtual_card.card_number)
      record.touch(:closed_at)
      render(record.reload.attributes)
    end

    protected
      def render(values)
        values["balance"] ||= values.delete("current_balance") if values.key?("current_balance") # Normalize key name
        # hiding a bit of the implementation details
        VirtualCard.new(values.except("id", "updated_at", "initial_balance"))
      end
  end
end
