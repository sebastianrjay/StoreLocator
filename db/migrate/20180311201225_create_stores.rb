class CreateStores < ActiveRecord::Migration[5.1]
  def change
    create_table :stores do |t|
      t.integer :nearest_store_id
      t.string :name
      t.string :location
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :full_address
      t.float :latitude
      t.float :longitude
      t.string :county

      t.timestamps
    end
    add_index :stores, :zip_code
    add_index :stores, :full_address
    add_index :stores, :latitude
    add_index :stores, :longitude
  end
end
