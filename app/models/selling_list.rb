# encoding: utf-8
class SellingList < ActiveRecord::Base
  attr_accessible :image_name, :ISBN, :author, :edition, :image_name, :language, :name, :publisher, :is_google, :book_list_id, :price, :bargain, :course, :missing, :cutting, :stains, :note, :email_c, :FB_c,
                  :phone, :addition, :available
  belongs_to :book_list
  belongs_to :user
  has_many   :selling_list_areas, :dependent => :destroy 
  
  validates :book_list_id, :presence => true
  validates :user_id, :presence =>{:message => "請先登入"}
  validates :price, :numericality => { :only_integer => true, :greater_than_or_equal_to=> 0, :less_than_or_equal_to=>9999, :message=>"價錢範圍為0-9999元"  } 
  #=========================for saving book_list  
  attr_accessor :name
  attr_accessor :author 
  attr_accessor :ISBN
  attr_accessor :edition
  attr_accessor :language
  attr_accessor :publisher
  attr_accessor :image_name
  #=========================for saving photo
  attr_accessor :photo_source
end
