# frozen_string_literal: true

require "active_record"
require "erb"

class Checkout
  attr_reader :promotional_rules, :total, :basket, :total_price_discount_applied_flag, :result

  def initialize(promotional_rules = {})
    raise TypeError, "expected a Hash, got #{promotional_rules.class.name}" unless promotional_rules.is_a? Hash
    raise KeyError, "expected Hash with optional keys 'product_discounts' and 'total_price_discount" unless correct_keys?(promotional_rules)

    @promotional_rules = promotional_rules
    @total = 0
    @basket = Basket.new
    establish_connection
  end

  def correct_keys?(promotional_rules)
    (promotional_rules.keys - %i[product_discounts total_price_discount]).empty?
  end

  # maybe facilitate scanning multiple items at once
  # no structure for item given, assumed id
  def scan(item)
    # check for item id
    add_to_basket(item)
    calculate_total(item)
    puts "Item with ID '#{item}' has been added to the basket successfully!"
    @total
  end

  def calculate_total(item)
    item_price = item_price(item)
    if @total_price_discount_applied_flag
      item_discounted?(item) ? apply_item_and_total_discount(item, item_price) : apply_total_discount_on_item(item_price)
    else
      item_discounted?(item) ? apply_item_discount(item, item_price) : @total += item_price
      apply_total_discount if total_price_discounted?
    end
    @total = @total.ceil(2)
  end

  def item_price(item)
    # TODO: check if user has supplied price
    # TODO: facilitate DB name different from products, i.e. ask gem user for db name???
    find_price_sql(item)
  end

  def prepare_sql_statement(item)
    # TODO: keep seen items in cache or variable  !!!!!!!!!
    ActiveRecord::Base.sanitize_sql_array(["SELECT 'products'.'price' FROM 'products' WHERE 'products'.'id' = ?", item])
  end

  def apply_item_and_total_discount(item, item_price)
    item_prom_rules = @promotional_rules[:product_discounts][item]
    item_basket_count = @basket.items[item]
    total_discount = (1 - @promotional_rules[:total_price_discount][:percent] / 100.00)
    @total += item_and_total(item_basket_count, item_prom_rules, total_discount, item_price)
  end

  def item_and_total(item_basket_count, item_prom_rules, total_discount, item_price)
    if item_basket_count == item_prom_rules[:count]
      (item_basket_count * item_prom_rules[:price] - (item_basket_count - 1) * item_price) * total_discount
    else
      item_basket_count * item_prom_rules[:price] * total_discount
    end
  end

  def apply_total_discount_on_item(item_price)
    @total += item_price * (1 - @promotional_rules[:total_price_discount][:percent] / 100.00)
  end

  def item_discounted?(item)
    return false unless item_in_discounts?(item)

    @basket.items[item] >= @promotional_rules[:product_discounts][item][:count]
  end

  def item_in_discounts?(item)
    @promotional_rules[:product_discounts] && @promotional_rules[:product_discounts][item]
  end

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

  def find_price_sql(item)
    sanitized_query = prepare_sql_statement(item)
    results = ActiveRecord::Base.connection.exec_query(sanitized_query)
    results.rows.first.first if results.present?
  end

  def establish_connection
    db_config = setup_db_config
    ActiveRecord::Base.establish_connection(adapter: db_config["adapter"], database: db_config["database"])
  end

  def setup_db_config
    defined?(Rails) && defined?(Rails.env) ? rails_db_config : non_rails_db_config
  end

  def rails_db_config
    Rails.application.config.database_configuration[Rails.env]
  end

  def non_rails_db_config
    # TODO: use current database instead of development
    YAML.safe_load(ERB.new(File.read("./config/database.yml")).result, aliases: true)["development"]
  end

  # maybe add remove item function

  def add_to_basket(item)
    @basket.items[item] ? @basket.items[item] += 1 : @basket.items[item] = 1
  end
end
