class Store < ApplicationRecord
  belongs_to :nearest_store, class_name: 'Store', optional: true
  validates_presence_of :address, :city, :state, :zip_code

  geocoded_by :full_address
  after_validation :set_full_address
  after_validation :geocode

  def to_txt(distance_str = nil)
    result = distance_str.nil? ? "" : "Distance: #{distance_str}\n"
    
    as_json(except: [:id, :created_at, :updated_at]).each do |attr, value|
      result += "#{attr.titleize}: #{value}\n"
    end

    result
  end

  private

  def set_full_address
    self.full_address = [address, city, state, zip_code].join(', ')
  end
end
