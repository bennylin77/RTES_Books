class SellingListArea < ActiveRecord::Base
  attr_accessible :school_list_id, :location, :selling_list_id
  belongs_to :selling_list
end
