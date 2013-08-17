class AddVerifiedToSchoolLists < ActiveRecord::Migration
  def change
    add_column :school_lists, :verified, :boolean, :default => true, :null => false
  end
end
