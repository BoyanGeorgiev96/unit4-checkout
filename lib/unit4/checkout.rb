# frozen_string_literal: true

require_relative "checkout/version"
require_relative "checkout/checkout"
require_relative "checkout/basket"
require_relative "checkout/connection"
require_relative "checkout/price_query"
require_relative "checkout/exceptions"

module Unit4
  # the main module for the gem, no code really needed here with the current structure
  module Checkout; end
end
