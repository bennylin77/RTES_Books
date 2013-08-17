# encoding: utf-8
class MySellingController < ApplicationController
  
  before_filter :checkUserLogin
  before_filter :checkUser

  def show
     @my_selling_list = SellingList.find(params[:id])
     @requesting_lists=@my_selling_list.book_list.requesting_lists
  end
  
  def edit
    @my_selling_list = SellingList.find(params[:id])
    
     if !@my_selling_list.book_list.selling_lists.empty?     
      @chart_selling=google_chart_selling_list(@my_selling_list.book_list)      
      @average_price=@my_selling_list.book_list.selling_lists.average("price")
     end 
  end

  def update
    @my_selling_list = SellingList.find(params[:id])
    @my_selling_list.selling_list_areas.destroy_all
    params[:area].each_with_index do |value, index|
      if !params[:area][index.to_s].blank?
       @my_selling_list.selling_list_areas<<SellingListArea.new(:school_list_id=>params[:area][index.to_s], :location=>params[:location][index.to_s])
      end
    end

    respond_to do |format|
      if @my_selling_list.update_attributes(params[:my_selling_list])
        format.html { redirect_to  "/my_selling/"+@my_selling_list.id.to_s ,notice: '成功修改賣書單!' }
      else
        @my_selling_list.valid?
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @my_selling_list = SellingList.find(params[:id])
    @my_selling_list.destroy
    redirect_to "/main/myBookLists"  
  end
  
  def repost
    @my_selling_list = SellingList.find(params[:id]) 
    if (Time.now-@my_selling_list.created_at)>24*60*60
      @my_selling_list.created_at=Time.now
      @my_selling_list.available=true
      @my_selling_list.save!
    end  
    redirect_to "/main/myBookLists"     
  end

  def unavailable
    @my_selling_list = SellingList.find(params[:id])   
    @my_selling_list.available=false
    @my_selling_list.save!
    redirect_to "/main/myBookLists"          
  end
  
protected
  def checkUser
    if SellingList.find(params[:id]).user_id!=session[:user_id]
     redirect_to root_url
    end
  end 
end
