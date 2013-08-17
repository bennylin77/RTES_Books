class ChangeSellingAndRequestingAreaToSchoolListId < ActiveRecord::Migration

  def change
    rename_column :selling_list_areas, :area, :school_list_id
    change_column :selling_list_areas, :school_list_id, :integer
    rename_column :requesting_list_areas, :area, :school_list_id
    change_column :requesting_list_areas, :school_list_id, :integer
  end

end
