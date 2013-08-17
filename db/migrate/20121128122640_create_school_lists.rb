class CreateSchoolLists < ActiveRecord::Migration
  def change
    create_table :school_lists, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8'  do |t|
      t.string :english_name
      t.string :chinese_name
      t.string :icon_name

      t.timestamps
    end
  end
end
