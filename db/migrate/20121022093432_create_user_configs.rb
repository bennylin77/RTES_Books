class CreateUserConfigs < ActiveRecord::Migration
  def change
    create_table :user_configs, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :user_id
      t.boolean :sys_selling_email, :default => true, :null => false     
      t.boolean :sys_requesting_email, :default => true, :null => false   
      t.timestamps
    end
  end
end
