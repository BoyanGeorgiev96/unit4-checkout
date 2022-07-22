# frozen_string_literal: true

# used for querying the database for the non-discounted product price
class PriceQuery
  def initialize(item)
    @sanitized_query = prepare_sql_statement(item)
  end

  def prepare_sql_statement(item)
    # TODO: keep seen items in cache or variable  !!!!!!!!!
    # Future work: facilitate DB table name different from products, i.e. ask gem user for db name
    ActiveRecord::Base.sanitize_sql_array(["SELECT 'products'.'price' FROM 'products' WHERE 'products'.'id' = ?", item])
  end

  def find_price
    results = ActiveRecord::Base.connection.exec_query(@sanitized_query)
    results.rows.first.first if results.present?
  end
end
