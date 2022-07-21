# frozen_string_literal: true

require "active_record"
require "erb"

class Checkout
  attr_reader :promotional_rules, :total, :basket, :price_discount_applied_flag

  # {product_discounts: {001: {count:2, price: 3.25}, 004: {count:2, price: 3.25}}, total_price_discount: $50}
  def initialize(promotional_rules)
    # maybe raise another error if keys aren't ids or total price, possibly total_item_count
    raise TypeError, "expected a Hash, got #{promotional_rules.class.name}" unless promotional_rules.is_a? Hash

    @promotional_rules = promotional_rules
    @total = 0
    @basket = Basket.new
    establish_connection
  end

  # maybe facilitate scanning multiple items at once
  # no structure for item given, assumed id
  def scan(item)
    # check for item id
    add_to_basket(item)
    calculate_total(item)
    puts "#{item.capitalize} has been added to the basket successfully!"
  end

  def calculate_total(item)
    item_price = find_item_price(item)
    new_discount_available?(item) ? apply_discounts : @total += item_price
    @total
  end

  def find_item_price(item)
    query = "SELECT * FROM 'users' WHERE 'users'.'id' = ?"
    sanitized_query = ActiveRecord::Base.sanitize_sql_array([query, item])
    execute_statement(sanitized_query)
    ActiveRecord::Base.connection.exec_query(sanitized_query)
  end

  def apply_discounts; end

  def new_discount_available?(item); end

  def execute_statement(sql)
    results = ActiveRecord::Base.connection.exec_query(sql)
    results if results.present?
  end

  def establish_connection
    db_config = setup_db_config
    ActiveRecord::Base.establish_connection(adapter: db_config["adapter"], database: db_config["database"])
  end

  def setup_db_config
    if defined? Rails && defined? Rails.env
      Rails.application.config.database_configuration[Rails.env]
    else
      # TODO: use current database instead of development
      YAML.safe_load(ERB.new(File.read("./config/database.yml")).result, aliases: true)["development"]
    end
  end

  # maybe add remove item function

  def add_to_basket(item)
    @basket[item] ? @basket["item"] += 1 : @basket["item"] = 1
  end
end
