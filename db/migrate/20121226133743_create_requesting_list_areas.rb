class CreateRequestingListAreas < ActiveRecord::Migration
  def change
    create_table :requesting_list_areas, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :requesting_list_id
      t.string :area
      t.string :location

      t.timestamps
    end
  end
end
