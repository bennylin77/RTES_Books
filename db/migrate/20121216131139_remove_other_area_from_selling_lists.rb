class RemoveOtherAreaFromSellingLists < ActiveRecord::Migration
  def change
    remove_column :selling_lists, :other_area
  end
end
