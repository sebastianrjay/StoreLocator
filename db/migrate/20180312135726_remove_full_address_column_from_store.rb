class RemoveFullAddressColumnFromStore < ActiveRecord::Migration[5.1]
  def change
    remove_column :stores, :full_address
  end
end
