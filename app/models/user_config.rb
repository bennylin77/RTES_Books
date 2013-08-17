class UserConfig < ActiveRecord::Base
  attr_accessible :sys_selling_email, :user_id, :sys_requesting_email, :default_trading_school, :default_index
  belongs_to :user
end
