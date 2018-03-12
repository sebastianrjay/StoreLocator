# Local Setup

1. Install ruby, PostgreSQL and the bundler gem
1. Start PostgreSQL locally
1. Run `bundle install`
1. Run `rake db:create db:migrate`
1. Run `rake stores:import` to import all stores from the CSV

# Store Locator Script Usage

```
Usage:
    rails runner find_store.rb --address="<address>"
    rails runner find_store.rb --address="<address>" [--units=(mi|km)] [--output=text|json]
    find_store --zip=<zip>
    find_store --zip=<zip> [--units=(mi|km)] [--output=text|json]

Options:
    -a, --address="<address>"        Address
                                       Find nearest store to this address. If there are multiple best-matches, return the first.
    -z, --zip=<zip>                  ZIP Code
                                       Find nearest store to this zip code. If there are multiple best-matches, return the first.
    -u, --units=(mi|km)              Units
                                       Display units in miles or kilometers [default: mi]
    -o, --output=(json|text)         Output
                                       Format output in human-readable text, or in JSON (e.g. machine-readable) [default: text]
    -h, --help                       Show this message
```

# Store Locator Algorithm Summary

1. The latitude and longitude of the passed-in address or zip code is fetched 
via the [geocoder](https://github.com/alexreisner/geocoder) library.
2. We fetch all stores in the database where the latitude and longitude are both 
within 1.0 degrees of the passed-in location. If none are found, we try 2.0 
degrees. If none are found, we continue incrementing the largest possible lat 
and lng difference from the passed in value, until reaching a max of 10.0 
degrees. If no stores are found, the algorithm returns null without continuing.
3. Once a set of stores is found in step 2, we find the closest store to the 
passed-in location. To do this, we use the 
[Pythagorean theorem](https://en.wikipedia.org/wiki/Pythagorean_theorem) to 
calculate the hypotenuse distance between the passed-in point and each store's 
location, like this:

`Math.sqrt((|store_lat| - |location_lat|) ** 2 + (|store_lng| - |location_lng|) ** 2)`

4. We call `Geocoder::Calculations.distance_between(store, [lat, lng]` to find 
the distance from the passed-in location to the nearest store found in step 3, 
in miles or km. (Without this library, we could use the heuristic that each 
latitude and degree equates to ~69 miles. In practice, this value varies based 
on proximity to the equator and thus it's better to use the library.)

(Note that the [geocoder](https://github.com/alexreisner/geocoder) library 
fetches and saves the latitude and longitude of each address on creation, when 
imported from `lib/assets/store-locations.csv` via `rake stores:import`.)

**Assumptions** This codebase assumes that addresses are unique across stores, 
as they are in the CSV. Normally I would denormalize addresses into a separate 
table, and store an `address_id` field on any model with an address in case an 
address is shared by multiple models.

# Integration Tests

Run `bundle exec rspec spec/features` to run the integration tests. Note that 
they can only pass once the "Local Setup" steps above are complete.

**NOTE:** If you see an error like this when running the integration tests 
after seeding the database with `rake stores:import`:

`app/services/store_finder.rb:46:in `get_lat_lng': undefined method `data' for nil:NilClass (NoMethodError)`

then wait awhile until the Google Maps API query limit is no longer exceeded.

Certain queries seem to have been cached, and do not trigger the error.
