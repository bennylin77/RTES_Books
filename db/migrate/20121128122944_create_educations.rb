class CreateEducations < ActiveRecord::Migration
  def change
    create_table :educations, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :user_id
      t.integer :school_list_id
      t.string :degree
      t.timestamps
    end
  end
end
