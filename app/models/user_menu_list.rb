class UserMenuList < ActiveRecord::Base
  attr_accessible :user_id, :school_list_id
  belongs_to :user
  belongs_to :school_list
end
