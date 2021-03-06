# ActiveAdminImporter

Simple CSV imports for active_admin, that (shouldn't) destroy your servers memory.

### Features / differences from similar gems
1. Parses the CSV file one row at a time
2. Allows you to override the view to customize the form
3. Access to the current controller from the import definition
4. Can define any number of imports per resource

### Examples

``` ruby
::ActiveAdmin.register Product do
  define_import_for :products do
    each_row do |params, import|
      product_attributes = params.slice(*[:name, :price])
      product_attributes[:user_id] = import.controller.current_user.id
      import.model.create!(product_attributes)
    end
  end

  #Example: require headers to be present
  define_import_for :products_on_sale do
    required_headers "sale_price", "price"

    each_row do |params, import|
      product_attributes = params.slice(*[:name, :price, :sale_price])
      product_attributes[:user_id] = import.controller.current_user.id
      import.model.create!(product_attributes)
    end
  end

  # Example: using a custom view
  # assume the view has a dropdown which allows you to select a particular store during import
  define_import_for :products_for_store do
    view "myactiveadmin/products/upload_products_for_store_csv"

    each_row do |params, import|
      product_attributes = params.slice(*[:name, :price, :sale_price])
      product_attributes[:user_id] = import.controller.current_user.id
      product_attributes[:store_id] = import.controller.params["store_id"]
      import.model.create!(product_attributes)
    end
  end

  # Example: using a Trax::Core transformer class,
  # or transformer that responds to to_hash
  define_import_for :products_for_store do
    view "myactiveadmin/products/upload_products_for_store_csv"
    transformer ::ProductForStoreTransformer

    each_row do |params, import|
      product_attributes[:user_id] = import.controller.current_user.id
      product_attributes[:store_id] = import.controller.params["store_id"]
      import.model.create!(product_attributes)
    end
  end

  # Example: using transform as callback
  define_import_for :products_for_store do
    view "myactiveadmin/products/upload_products_for_store_csv"
    transform { |row| ::ProductForStoreTransformer.new(row).to_hash }

    each_row do |params, import|
      product_attributes[:user_id] = import.controller.current_user.id
      product_attributes[:store_id] = import.controller.params["store_id"]
      import.model.create!(product_attributes)
    end
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_admin_importer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_admin_importer

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/active_admin_importer.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
