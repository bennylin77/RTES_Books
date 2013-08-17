class AddDefaultIndexToUserConfig < ActiveRecord::Migration
  def change
    add_column :user_configs, :default_index, :string
  end
end
