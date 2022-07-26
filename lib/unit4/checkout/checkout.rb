# frozen_string_literal: true

# the main class that is used for scaning the items and applying the discounts
class Checkout
  attr_reader :total

  def initialize(promotional_rules = {})
    # custom exceptions for incorrect Checkout.new({...}) parameters
    raise PromotionalRulesTypeError, promotional_rules.class.name unless promotional_rules.is_a? Hash
    raise PromotionalRulesForbiddenKeys unless correct_keys?(promotional_rules)

    @promotional_rules = promotional_rules
    @total = 0
    @basket = Basket.new
    @saved_prices = {}
    create_db_connection
  end

  # no structure for the item variable item given, assumed id from sample data input
  def scan(item)
    add_to_basket(item)
    calculate_total(item)
    puts "Item with ID '#{item}' has been added to the basket successfully!"
  end

  private

  def correct_keys?(promotional_rules)
    (promotional_rules.keys - %i[product_discounts total_price_discount]).empty?
  end

  def create_db_connection
    Connection.new
  end

  # add to total according to several criteria:
  # is the total already discounted, is the item eligible for a discount based on the number of times it got scanned
  # the function also decides whether both discounts or only one is required

  def calculate_total(item)
    item_price = item_price(item)
    # use a hash to store seen non-discounted prices so the database is not queried when we already have the info
    @saved_prices[item] ||= item_price
    if @total_price_discount_applied_flag
      item_discounted?(item) ? apply_item_and_total_discount(item, item_price) : apply_total_discount_on_item(item_price)
    else
      item_discounted?(item) ? apply_item_discount(item, item_price) : @total += item_price
      # apply total discount if the last item moved the price sent the discount threshold
      apply_total_discount if total_price_discounted?
    end
    @total = @total.round(2)
  end

  def item_price(item)
    # Future work: facilitate DB table name different from products, i.e. ask gem user for db name
    PriceQuery.new(item).find_price(@saved_prices)
  end

  # apply both types of discounts at the same time
  def apply_item_and_total_discount(item, item_price)
    item_prom_rules = @promotional_rules[:product_discounts][item]
    item_basket_count = @basket.items[item]
    total_discount = (1 - @promotional_rules[:total_price_discount][:percent] / 100.00)
    @total += item_and_total(item_basket_count, item_prom_rules, total_discount, item_price)
  end

  # if it is the first time the specific item has been discounted we discount all its other instances
  # no need to keep track of every item in-memory, so we just use the total count of the item to remove
  # the old sum for this specific item and add the new discounted one
  def item_and_total(item_basket_count, item_prom_rules, total_discount, item_price)
    if item_basket_count == item_prom_rules[:count]
      (item_basket_count * item_prom_rules[:price] - (item_basket_count - 1) * item_price) * total_discount
    else
      item_basket_count * item_prom_rules[:price] * total_discount
    end
  end

  # used when only total discount is needed for a non-discounted scanned item, e.g. when the total sum is over $60.00
  def apply_total_discount_on_item(item_price)
    @total += item_price * (1 - @promotional_rules[:total_price_discount][:percent] / 100.00)
  end

  # if item is not in the promotional rules returns false
  # otherwise check if the item count in the basket is higher than the promotional rules threshold
  def item_discounted?(item)
    return false unless item_in_discounts?(item)

    @basket.items[item] >= @promotional_rules[:product_discounts][item][:count]
  end

  def item_in_discounts?(item)
    @promotional_rules[:product_discounts] && @promotional_rules[:product_discounts][item]
  end

  # only applies the specific item discount. same reasoning as the "item_and_total" function.
  def apply_item_discount(item, item_price)
    item_prom_rules = @promotional_rules[:product_discounts][item]
    item_basket_count = @basket.items[item]
    @total += if item_basket_count == item_prom_rules[:count]
                item_basket_count * item_prom_rules[:price] - (item_basket_count - 1) * item_price
              else
                item_prom_rules[:price]
              end
  end

  def total_price_discounted?
    return false unless total_price_in_discounts?

    @total >= @promotional_rules[:total_price_discount][:price]
  end

  def total_price_in_discounts?
    @promotional_rules[:total_price_discount] && @promotional_rules[:total_price_discount][:price]
  end

  def apply_total_discount
    @total *= (1 - @promotional_rules[:total_price_discount][:percent] / 100.00)
    @total_price_discount_applied_flag = true
  end

  def add_to_basket(item)
    @basket.items[item] ? @basket.items[item] += 1 : @basket.items[item] = 1
  end
end
