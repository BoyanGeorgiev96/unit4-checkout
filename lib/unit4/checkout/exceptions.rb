# frozen_string_literal: true

class PromotionalRulesTypeError < TypeError
  def initialize(class_name, msg = "expected a Hash, got ", exception_type = "custom")
    msg += class_name
    @exception_type = exception_type
    super(msg)
  end
end

class PromotionalRulesForbiddenKeys < TypeError
  def initialize(msg = "expected Hash with optional keys 'product_discounts' and 'total_price_discount", exception_type = "custom")
    @exception_type = exception_type
    super(msg)
  end
end
