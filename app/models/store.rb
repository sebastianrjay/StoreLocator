class Store < ApplicationRecord
  belongs_to :nearest_store, class_name: 'Store', optional: true
  validates_presence_of :address, :city, :state, :zip_code

  geocoded_by :full_address
  after_validation :set_full_address
  after_validation :geocode

  private

  def set_full_address
    self.full_address = [address, city, state, zip_code].join(', ')
  end
end
