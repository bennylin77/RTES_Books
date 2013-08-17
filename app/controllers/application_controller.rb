# encoding: UTF-8
class ApplicationController < ActionController::Base 
  
  include Authen
  protect_from_forgery
  rescue_from FbGraph::Exception, :with => :fb_graph_exception

  def dns_name
      'http://rtes.funeasy.tw'
  end

  def fb_graph_exception(e)
    flash[:error] = {
      :title   => e.class,
      :message => e.message
    }
    current_user.try(:destroy)
    redirect_to root_url
  end
  
  def google_chart_selling_list(book_list)
      chart_data=Hash.new(0)            
      data_table = GoogleVisualr::DataTable.new
      # Add Column Headers
      data_table.new_column('string', 'user' )
      data_table.new_column('number', '價格')     
      # Add Rows and Values 
      
      book_list.selling_lists.each do |selling_list|
        if !selling_list.user.FB_username.nil?
          data_table.add_row( [selling_list.user.FB_username+" 在"+selling_list.created_at.to_formatted_s(:short) , selling_list.price])
        else
          data_table.add_row( [selling_list.user.email+" 在"+selling_list.created_at.to_formatted_s(:short) , selling_list.price])        
        end
      end
      
      option = { width: 400, height: 150, title: "此書價錢分佈", chartArea: {left:35,top:30}, colors:['#66E066'] }    
      GoogleVisualr::Interactive::  ColumnChart.new(data_table, option)
  end
  
protected

  def checkUserLogin
    unless User.find_by_id(session[:user_id])
      session[:original_uri]=request.fullpath 
      flash[:notice]="請先登入 謝謝!"
      redirect_to root_url
    end
  end 
   
end
