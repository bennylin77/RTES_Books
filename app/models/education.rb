class Education < ActiveRecord::Base
  attr_accessible :school_list_id, :degree, :user_id
  belongs_to :user
  belongs_to :school_list
end
