class RequestingListArea < ActiveRecord::Base
  attr_accessible :school_list_id, :location, :requesting_list_id
  belongs_to :requesting_list
end
