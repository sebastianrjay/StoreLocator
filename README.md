# Local Setup

1. Install ruby, PostgreSQL and the bundler gem
1. Start PostgreSQL locally
1. Run `bundle install`
1. Run `rake db:create db:migrate`
1. Run `rake stores:import` to import all stores from the CSV. It seems that the 
occasional `Google API error: over query limit.` output is only a warning.

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
