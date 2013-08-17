class User < ActiveRecord::Base
  #attr_accessible :fb_identifier
  has_many :selling_lists
  has_many :requesting_lists
  has_many :educations
  has_many :user_menu_lists  
  has_one  :user_config
end
