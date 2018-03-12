require 'optparse'

class StoreFinderOptionParser
  def self.parse(args)
    options = { output: 'text', units: 'mi' }

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage:
    rails runner find_store.rb --address=\"<address>\"
    rails runner find_store.rb --address=\"<address>\" [--units=(mi|km)] [--output=text|json]
    find_store --zip=<zip>
    find_store --zip=<zip> [--units=(mi|km)] [--output=text|json]
"

      opts.separator ''
      opts.separator 'Options:'

      opts.on('-a', '--address="<address>"',
              'Address',
              '  Find nearest store to this address. If there are multiple best-matches, return the first.') do |address|
        options[:address] = address
      end

      opts.on('-z', '--zip=<zip>',
              'ZIP Code',
              '  Find nearest store to this zip code. If there are multiple best-matches, return the first.') do |zip|
        options[:zip] = zip
      end

      opts.on('-u', '--units=(mi|km)',
              'Units',
              '  Display units in miles or kilometers [default: mi]') do |units|
        options[:units] = units
      end

      opts.on('-o', '--output=(json|text)',
              'Output',
              '  Format output in human-readable text, or in JSON (e.g. machine-readable) [default: text]') do |output|
        options[:output] = output
      end

      # No argument, shows at tail.  This will print an options summary.
      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end

    begin
      opt_parser.parse!(args)
      if options[:address].nil? && options[:zip].nil?
        raise OptionParser::MissingArgument.new('--address or --zip required')
      end
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
      puts "\n#{$!.to_s}\n\n"
      puts opt_parser
      exit
    end

    options
  end
end
