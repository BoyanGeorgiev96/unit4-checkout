## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add unit4-checkout

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install unit4-checkout

## Usage

Please note the gem relies on a database connection to the "products" table. Please make sure you have that table created and products have the 'price' attribute (float, non-nil).

Create a Checkout instance with OPTIONAL promotional rules:

```
co = Checkout.new(promotional_rules)
```
The promotional rules need to have the following structure (note the "=>" after the item id that is used for a key):

```
promotional_rules = { product_discounts: { "001" => { count: 2, price: 8.50 } },
                          total_price_discount: { price: 60.00, percent: 10 } }
```

Scanning items:

```
co.scan("001")
```

Access the total price:

```
co.total
```

## Testing

The gem has its own database config and database for testing that complies with the requested format

To run the test suite in the console using RSpec, run

```
rspec
```

## Future work

Use a user supplied database instead of the "products" one. Different attribute names for price can be incorporated too.

Test the gem thoroughly against a plain Ruby project. Environment will either be (most likely) non-existent there so some changes in the `Connection.non_rails_db_config` will be needed.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/BoyanGeorgiev96/unit4-checkout.
