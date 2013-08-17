class SchoolList < ActiveRecord::Base
  attr_accessible :chinese_name, :english_name, :icon_name, :verified
  has_many :educations
  has_many :user_menu_lists
  
  default_scope :order => 'chinese_name'
end
