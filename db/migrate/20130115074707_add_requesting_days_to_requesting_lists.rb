class AddRequestingDaysToRequestingLists < ActiveRecord::Migration
  def change
     add_column :requesting_lists, :requesting_days, :integer
  end
end
