# encoding: utf-8
class BookList < ActiveRecord::Base
  attr_accessible :ISBN, :author, :edition, :image_name, :language, :name, :publisher, :is_google
  has_many :selling_lists , :order => "updated_at"
  has_many :requesting_lists , :order => "updated_at"
  
  validates :name, :presence => { :message =>"您未填寫書名" }
  #validates :ISBN, :uniqueness =>{ :message =>"ISBN已經使用過" }, :presence => { :message =>"您未填寫ISBN" },  :numericality => { :only_integer => true, :message=>"ISBN不是一個數字"  } 
  validates :ISBN, :isbn_format=>{ :message=>"不是正確的ISBN" }


  attr_accessor :chart_selling
  attr_accessor :average_price
end


