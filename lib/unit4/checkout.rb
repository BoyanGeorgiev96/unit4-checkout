# frozen_string_literal: true

require_relative "checkout/version"
require_relative "checkout/checkout"
require_relative "checkout/basket"
require_relative "checkout/connection"
require_relative "checkout/price_query"
require_relative "checkout/exceptions"

module Unit4
  module Checkout
    class Error < StandardError; end
    # Your code goes here...
  end
end
