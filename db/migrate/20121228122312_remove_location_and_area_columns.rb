class RemoveLocationAndAreaColumns < ActiveRecord::Migration

  def change
    remove_column :selling_lists, :area_1
    remove_column :selling_lists, :area_2
    remove_column :selling_lists, :area_3
    remove_column :selling_lists, :location_1
    remove_column :selling_lists, :location_2
    remove_column :selling_lists, :location_3
    
    remove_column :requesting_lists, :area_1
    remove_column :requesting_lists, :area_2
    remove_column :requesting_lists, :area_3
    remove_column :requesting_lists, :location_1
    remove_column :requesting_lists, :location_2
    remove_column :requesting_lists, :location_3          
  end
end
