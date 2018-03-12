class StoreFinder
  DEFAULT_FORMAT = 'text'
  DEFAULT_UNITS = 'mi'
  MAX_LAT_LNG_DIFFERENCE = 10

  def initialize(options)
    @address = options.with_indifferent_access[:address]
    @zip = options.with_indifferent_access[:zip]
    @output = (options.with_indifferent_access[:output] || DEFAULT_FORMAT).to_s
    @units = (options.with_indifferent_access[:units] || DEFAULT_UNITS).to_sym
  end

  def locate
    lat, lng = get_lat_lng
    nearest_store = find_nearest_store(lat, lng)
    print_store_info(nearest_store, lat, lng)
  end

  private

  def compute_lat_lng_distance(store, lat, lng) # Using Pythagorean theorem
    vertical_distance_squared = (store.latitude.abs - lat.abs) ** 2
    horizontal_distance_squared = (store.longitude.abs - lng.abs) ** 2
    Math.sqrt(vertical_distance_squared + horizontal_distance_squared)
  end

  def compute_human_readable_distance(nearest_store, lat, lng)
    store = [nearest_store.latitude, nearest_store.longitude]
    Geocoder::Calculations.distance_between(store, [lat, lng], units: @units)
  end

  def find_nearest_store(lat, lng)
    nearest_store = nil

    1.upto(MAX_LAT_LNG_DIFFERENCE) do |lat_lng_bound|
      stores = nearest_stores(lat, lng, lat_lng_bound)
      nearest_store = stores.min_by {|s| compute_lat_lng_distance(s, lat, lng) }
      break if nearest_store.present?
    end

    nearest_store
  end

  def get_lat_lng
    api_result = Geocoder.search(@address || @zip).first
    lat = api_result.data["geometry"]["location"]["lat"]
    lng = api_result.data["geometry"]["location"]["lng"]
    [lat, lng]
  end

  def nearest_stores(lat, lng, lat_lng_bound)
    max_lat, min_lat = lat + lat_lng_bound, lat - lat_lng_bound
    max_lng, min_lng = lng + lat_lng_bound, lng - lat_lng_bound
    query = "latitude >= ? AND latitude <= ? AND longitude >= ? AND longitude <= ?"
    Store.where(query, min_lat, max_lat, min_lng, max_lng)
  end

  def null_store
    @output == 'json' ? nil.to_json : 'No store found.'
  end

  def print_store_info(nearest_store, lat, lng)
    return puts null_store if nearest_store.nil?
    distance = compute_human_readable_distance(nearest_store, lat, lng)
    distance_str = "#{distance.round(2)} #{@units}"

    if @output == 'json'
      distance_info = { "distance" => distance_str }
      result = distance_info.merge(nearest_store.as_json)
      p result.to_json
    else
      puts nearest_store.to_txt(distance_str)
    end
  end
end
