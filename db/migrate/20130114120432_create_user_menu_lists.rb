class CreateUserMenuLists < ActiveRecord::Migration
  def change
    create_table :user_menu_lists, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8'  do |t|
      t.integer :user_id
      t.integer :school_list_id
      t.timestamps
    end
  end
end
