class CreateTableRequestingList < ActiveRecord::Migration
   def change
    create_table :requesting_lists, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :user_id
      t.integer :book_list_id
      t.integer :prefer_price_from
      t.integer :prefer_price_to
      t.string :missing
      t.string :cutting
      t.string :stains
      t.string :note
      t.string :course          
      t.string :phone
      t.string :area
      t.string :other_area
      t.boolean :email_c
      t.boolean :FB_c  
      t.timestamps
    end
  end
end
