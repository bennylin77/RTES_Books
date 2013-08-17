class AddAvailableToSellingListsAndRequestingLists < ActiveRecord::Migration
  def change
    add_column :requesting_lists, :available, :boolean, :default => true, :null => false
    add_column :selling_lists, :available, :boolean, :default => true, :null => false
  end
end
