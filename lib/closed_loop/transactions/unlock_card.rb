module ClosedLoop
  module Transactions
    class UnlockCard < LockCard # 2016
      def initialize(card_number:, action: :unlock, reason: nil, ean: nil)
        super
      end
    end
  end
end
