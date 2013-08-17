class RemoveOtherAreaFromRequestingLists < ActiveRecord::Migration
  def change
    remove_column :requesting_lists, :other_area
  end
end
