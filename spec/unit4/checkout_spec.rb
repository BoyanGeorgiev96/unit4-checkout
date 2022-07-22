# frozen_string_literal: true

RSpec.describe Unit4::Checkout do
  it "has a version number" do
    expect(Unit4::Checkout::VERSION).not_to be nil
  end

  it "raises custom type error " do
    expect { Checkout.new("not-a-hash") }.to raise_error(PromotionalRulesTypeError)
  end

  it "raises custom forbidden keys error " do
    expect { Checkout.new({ "forbidden_key": 1 }) }.to raise_error(PromotionalRulesForbiddenKeys)
  end

  it "returns correct total on no available discounts" do
    co = Checkout.new
    10.times { co.scan("001") }
    expect (co.total.to_d - 92.5.to_d).abs < Float::EPSILON
  end

  it "applies the correct discount the first time the item count threshold is hit" do
    promotional_rules = { product_discounts: { "001" => { count: 2, price: 8.50 } } }
    co = Checkout.new(promotional_rules)
    2.times { co.scan("001") }
    expect (co.total.to_d - 17.00.to_d).abs < Float::EPSILON
  end

  it "applies the correct discount on all subsequent items as well" do
    promotional_rules = { product_discounts: { "001" => { count: 2, price: 8.50 } } }
    co = Checkout.new(promotional_rules)
    5.times { co.scan("001") }
    expect (co.total.to_d - 42.50.to_d).abs < Float::EPSILON
  end

  it "applies the correct total price discount" do
    promotional_rules = { total_price_discount: { price: 60.00, percent: 10 } }
    co = Checkout.new(promotional_rules)
    2.times { co.scan("001") }
    expect (co.total.to_d - 81.00.to_d).abs < Float::EPSILON
  end

  it "applies both discounts" do
    promotional_rules = { product_discounts: { "001" => { count: 2, price: 8.50 } },
                          total_price_discount: { price: 60.00, percent: 10 } }
    co = Checkout.new(promotional_rules)
    co.scan("001")
    co.scan("002")
    co.scan("001")
    co.scan("003")
    expect (co.total.to_d - 73.76.to_d).abs < Float::EPSILON
  end

  it "finds the correct item price from database" do
    co = Checkout.new
    expect (co.method("item_price").call("001").to_d - 9.25.to_d).abs < Float::EPSILON
  end

  it "finds correctly discounted items" do
    promotional_rules = { product_discounts: { "001" => { count: 2, price: 8.50 } } }
    co = Checkout.new(promotional_rules)
    2.times { co.method("add_to_basket").call("001") }
    expect(co.method("item_discounted?").call("001")).to be true
  end

  it "connects to the database succesffully" do
    Connection.new
    ActiveRecord::Base.connection
    expect(ActiveRecord::Base.connected?).to be true
  end

  it "sets the @total_price_discount_applied_flag correctly" do
    promotional_rules = { total_price_discount: { price: 60.00, percent: 10 } }
    co = Checkout.new(promotional_rules)
    # the flag is set on the last line and is therefore the return value
    expect(co.method("apply_total_discount").call).to be true
  end
end
