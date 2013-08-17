class CreateTableFacebook < ActiveRecord::Migration
   def change
    create_table :facebooks, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :identifier
      t.string :access_token
      t.timestamps
    end
  end
end
