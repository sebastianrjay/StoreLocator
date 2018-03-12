require 'rake'
load File.expand_path("../../../lib/tasks/stores.rake", __FILE__)
# make sure you set correct relative path 
Rake::Task.define_task(:environment)
Rake::Task['stores:import'].invoke

TEST_CASES = {
  '--zip=94114 --output=text' => "Distance: 1.95 mi
Name: San Francisco West
Location: SEC Geary Blvd. and Masonic Avenue
Address: 2675 Geary Blvd
City: San Francisco
State: CA
Zip Code: 94118-3400
Full Address: 2675 Geary Blvd, San Francisco, CA, 94118-3400
Latitude: 37.7821682
Longitude: -122.4464584
County: San Francisco County
",
  '--zip=94114 --output=json' => '"{\"distance\":\"1.95 mi\",\"id\":2899,\"name\":\"San Francisco West\",\"location\":\"SEC Geary Blvd. and Masonic Avenue\",\"address\":\"2675 Geary Blvd\",\"city\":\"San Francisco\",\"state\":\"CA\",\"zip_code\":\"94118-3400\",\"full_address\":\"2675 Geary Blvd, San Francisco, CA, 94118-3400\",\"latitude\":37.7821682,\"longitude\":-122.4464584,\"county\":\"San Francisco County\",\"created_at\":\"2018-03-11T23:29:06.295Z\",\"updated_at\":\"2018-03-11T23:29:06.295Z\"}"',
  '--address="1966A 15th St, San Francisco, CA, 94114"' => "Distance: 1.49 mi
Name: San Francisco West
Location: SEC Geary Blvd. and Masonic Avenue
Address: 2675 Geary Blvd
City: San Francisco
State: CA
Zip Code: 94118-3400
Full Address: 2675 Geary Blvd, San Francisco, CA, 94118-3400
Latitude: 37.7821682
Longitude: -122.4464584
County: San Francisco County
",
  '--address="1966A 15th St, San Francisco, CA, 94114" --output=json' => '"{\"distance\":\"1.49 mi\",\"id\":2899,\"name\":\"San Francisco West\",\"location\":\"SEC Geary Blvd. and Masonic Avenue\",\"address\":\"2675 Geary Blvd\",\"city\":\"San Francisco\",\"state\":\"CA\",\"zip_code\":\"94118-3400\",\"full_address\":\"2675 Geary Blvd, San Francisco, CA, 94118-3400\",\"latitude\":37.7821682,\"longitude\":-122.4464584,\"county\":\"San Francisco County\",\"created_at\":\"2018-03-11T23:29:06.295Z\",\"updated_at\":\"2018-03-11T23:29:06.295Z\"}"'
}

describe "find_store.rb script" do
  it 'prints help info when passed the -h flag' do
    output = `rails runner find_store.rb -h`
    expect(output).to include(StoreFinderOptionParser::BANNER)
  end

  it 'prints an error when not passed an --address, --zip or --help flag' do
    output = `rails runner find_store.rb --units=km`
    expect(output).to include('missing argument: --address or --zip required')
  end

  it 'outputs text and uses mi units by default' do
    default_output = `rails runner find_store.rb --zip=94114`
    text_output = `rails runner find_store.rb --zip=94114`
    expect(default_output).to eq(text_output)
    expect(text_output).to include('1.95 mi')
  end

  TEST_CASES.each do |options, output|
    it "prints the expected output when passed #{options}" do
      test_output = `rails runner find_store.rb #{options}`
      expect(test_output).to include(output)
    end
  end
end
