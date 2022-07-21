# frozen_string_literal: true

require "active_record"
require "erb"

class Checkout
  attr_reader :promotional_rules, :total, :basket, :price_discount_applied_flag, :result

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
    find_item_price(item)
    item_price = 3
    new_discount_available?(item) ? apply_discounts : @total += item_price
    @total
  end

  def find_item_price(item)
    query = "SELECT * FROM 'users' WHERE 'users'.'id' = ?"
    sanitized_query = ActiveRecord::Base.sanitize_sql_array([query, item])
    execute_statement(sanitized_query)
  end

  def apply_discounts; end

  def new_discount_available?(item); end

  def execute_statement(sql)
    results = ActiveRecord::Base.connection.exec_query(sql)
    @result = results if results.present?
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
