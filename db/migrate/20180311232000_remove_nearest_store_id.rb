class RemoveNearestStoreId < ActiveRecord::Migration[5.1]
  def change
    remove_column :stores, :nearest_store_id
  end
end
