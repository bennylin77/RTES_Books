# encoding: utf-8
class RequestingList < ActiveRecord::Base
  attr_accessible  :image_name, :book_list_id, :name, :author, :ISBN, :edition, :language, :publisher, :prefer_price_from, :prefer_price_to, :course, :missing, :cutting, :stains, :note, :email_c, :FB_c,
                   :phone, :requesting_days, :available
  belongs_to :book_list
  belongs_to :user
  has_many   :requesting_list_areas, :dependent => :destroy
  
  validates :book_list_id, :presence => true
  validates :user_id, :presence =>{:message => "請先登入"}
  validates :prefer_price_from, :numericality => { :only_integer => true, :greater_than_or_equal_to=> 0, :less_than_or_equal_to=>9999, :message=>"價錢範圍為0-9999元"  }
  validates :prefer_price_to, :numericality => { :only_integer => true, :greater_than_or_equal_to=> 0, :less_than_or_equal_to=>9999, :message=>"價錢範圍為0-9999元"  }
  
  validate :compare_price
  def compare_price
    if prefer_price_from.is_a?(Numeric) && prefer_price_to.is_a?(Numeric)
      if prefer_price_from > prefer_price_to
        errors.add(:compare_price, "價錢輸入範圍怪怪的喔!")
      end
    end
  end
  
  #=========================for saving book_list  
  attr_accessor :name
  attr_accessor :author 
  attr_accessor :ISBN
  attr_accessor :edition
  attr_accessor :language
  attr_accessor :publisher
  attr_accessor :image_name
  
end
