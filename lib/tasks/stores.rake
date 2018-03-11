require 'csv'

namespace :stores do
  desc "Import stores from CSV"
  task import: :environment do
    IMPORT_FILE = Rails.root.join('lib', 'assets', 'store-locations.csv')
    Rails.logger.info "Importing..."

    CSV.foreach(IMPORT_FILE, :headers => true) do |row|
      data = row.to_hash.transform_keys do |key|
        key.to_s.strip.underscore.gsub(' ', '_').gsub('store_', '')
      end
      # There seems to be a weird CSV encoding or read issue here wherein 
      # data.keys.first.chars contains empty string, and is unusable.
      # Uncomment byebug below and run:
      #   p faulty_store_name_key #=> "name"
      #   p "name" #=> "name"
      #   p faulty_store_name_key.chars #=> ["", "n", "a", "m", "e"]
      #   p "name".chars #=> ["n", "a", "m", "e"]
      #   p faulty_store_name_key.chars == "name".chars #=> false
      # to see the issue. Hence, eliminating the code below raises an 
      # UnknownAttributeError.
      faulty_store_name_key = data.keys.first
      # byebug
      store_name = data[faulty_store_name_key]
      data.delete(faulty_store_name_key)
      data["name"] = store_name
      
      existing_store = Store.where(data).first
      Store.create!(data) unless existing_store.present?
    end

    Rails.logger.info "Import complete."
  end
end
