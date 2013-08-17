class AddDefaultTradingSchoolToUserConfigs < ActiveRecord::Migration
  def change
    add_column :user_configs, :default_trading_school, :string
  end
end
