class CreateTableSellingList < ActiveRecord::Migration
   def change
    create_table :selling_lists, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :user_id
      t.integer :book_list_id
      t.integer :price
      t.string :bargain
      t.string :missing
      t.string :cutting
      t.string :stains
      t.string :note
      t.string :photo_name      
      t.string :phone
      t.string :area
      t.string :other_area
      t.string :course
      t.boolean :email_c
      t.boolean :FB_c
      t.text :addition
      t.timestamps
    end
  end
end
