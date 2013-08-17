class CreateTableUser < ActiveRecord::Migration
   def change
    create_table :users, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :FB_identifier
      t.string :email
      t.string :FB_username
      t.timestamps
    end
  end
end
