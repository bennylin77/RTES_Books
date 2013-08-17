class CreateTableBookList < ActiveRecord::Migration
  def change
    create_table :book_lists, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name
      t.string :author
      t.string :ISBN
      t.string :edition
      t.string :language
      t.string :publisher
      t.string :image_name
      t.boolean :is_google, :default => false, :null => false
      t.timestamps
    end
  end
end
