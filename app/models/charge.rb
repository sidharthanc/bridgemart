class Charge
  attr_accessor :description
  attr_accessor :rate
  attr_accessor :quantity
  attr_accessor :kind

  def initialize(fee, quantity, kind)
    @description = fee.description
    @rate = fee.rate
    @quantity = quantity
    @kind = kind
  end

  def price
    rate * quantity
  end
end
