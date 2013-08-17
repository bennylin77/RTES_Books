# encoding: utf-8
class MyRequestingController < ApplicationController
  
  before_filter :checkUserLogin
  before_filter :checkUser

  def show
    @my_requesting_list = RequestingList.find(params[:id])
    @selling_lists=@my_requesting_list.book_list.selling_lists
        
    if !@selling_lists.empty?     
      @chart_selling=google_chart_selling_list(@my_requesting_list.book_list)      
      @average_price=@selling_lists.average("price")
    end 
  end

  def edit
    @my_requesting_list = RequestingList.find(params[:id])
  end

  def update   
    @my_requesting_list = RequestingList.find(params[:id])
    @my_requesting_list.requesting_list_areas.destroy_all
    params[:area].each_with_index do |value, index|
      if !params[:area][index.to_s].blank?
       @my_requesting_list.requesting_list_areas<<RequestingListArea.new(:school_list_id=>params[:area][index.to_s], :location=>params[:location][index.to_s])
      end
    end

    respond_to do |format|
      if @my_requesting_list.update_attributes(params[:my_requesting_list])
        format.html { redirect_to  "/my_requesting/"+@my_requesting_list.id.to_s ,notice: '成功修改徵書單!' }
      else
        @my_requesting_list.valid?
        format.html { render action: "edit" }
      end
    end
    
  end

  def destroy    
    @my_requesting_list = RequestingList.find(params[:id])
    @my_requesting_list.destroy
    redirect_to "/main/myBookLists"   
  end
  
  def repost
    @my_requesting_list = RequestingList.find(params[:id]) 
    if (Time.now-@my_requesting_list.created_at)>24*60*60
      @my_requesting_list.created_at=Time.now
      @my_requesting_list.available=true
      @my_requesting_list.save!
    end
    redirect_to "/main/myBookLists"     
  end  
  
  def unavailable
    @my_requesting_list = RequestingList.find(params[:id])   
    @my_requesting_list.available=false
    @my_requesting_list.save!
    redirect_to "/main/myBookLists"       
  end
  
protected
  def checkUser
    if RequestingList.find(params[:id]).user_id!=session[:user_id]
      redirect_to root_url
    end
  end 
end
