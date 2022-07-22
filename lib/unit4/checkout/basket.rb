# frozen_string_literal: true

# basket should probably be separated from the checkout, hence this class
class Basket
  attr_accessor :items

  def initialize
    @items = {}
  end
end
