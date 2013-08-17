class AddAreaAndLocationToRequestingList < ActiveRecord::Migration
  def change
    rename_column :requesting_lists, :area ,:area_1
    add_column    :requesting_lists, :location_1, :string
    add_column    :requesting_lists, :area_2, :string
    add_column    :requesting_lists, :location_2, :string
    add_column    :requesting_lists, :area_3, :string
    add_column    :requesting_lists, :location_3, :string      
  end
end
