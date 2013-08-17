# encoding: utf-8
require 'will_paginate/array'
class MainController < ApplicationController

	before_filter :checkUserLogin, :only=>[:schoolOutline, :friendsBookLists, :myBookLists, :post_on_fb, :areaListShowing, :sendMessagejs ]
	
	#=============================================================================================================for index
	def index

      
	end
	
	def indexSelect
	  user=User.find_by_id(session[:user_id])
	  if user
	    if !user.user_config.default_index.blank?
	      redirect_to :action=>:schoolOutline, :english_name=>SchoolList.find(user.user_config.default_index).english_name
	    else   
        redirect_to :action=>:allOutline	    
	    end
	  else
	    redirect_to :action=>:allOutline
	  end    
	end

  #=============================================================================================================for local and all

  def schoolOutline
    if User.find_by_id(session[:user_id]).educations.count!=0 or !params[:english_name].blank?
      if params[:search].blank?  
        @english_name=params[:english_name]
        @chinese_name=SchoolList.find_by_english_name(@english_name).chinese_name
        
        @area_requesting_lists=RequestingList.joins(:requesting_list_areas).where('requesting_list_areas.school_list_id = ?', SchoolList.find_by_english_name(@english_name) )
        @area_selling_lists=SellingList.joins(:selling_list_areas).where('selling_list_areas.school_list_id = ?', SchoolList.find_by_english_name(@english_name) )
      
      
        @area_lists=(@area_requesting_lists+@area_selling_lists).sort{|a,b| b.created_at <=> a.created_at }
        @area_lists=@area_lists.paginate(:per_page => 30, :page => params[:page])
        
        if request.xhr?
          sleep(3) # make request a little bit slower to see loader :-)
          render :partial => "layouts/showing_list_area", :collection => @area_lists    
        else       
          @area_lists    
        end
      else
        @english_name=params[:search][:english_name]
        @term=params[:search][:term] 
        @chinese_name=SchoolList.find_by_english_name(@english_name).chinese_name
        @search_c=true        
        @area_selling_lists= SellingList.find(:all, 
                                              :conditions => ["selling_list_areas.school_list_id = ? and (selling_lists.course LIKE ? or book_lists.name LIKE ? or book_lists.author LIKE ? or book_lists.ISBN LIKE ?)",
                                              SchoolList.find_by_english_name(@english_name).id,
                                              "%#{@term}%", "%#{@term}%", 
                                              "%#{@term}%", "%#{@term}%"],
                                              :joins => [:book_list, :selling_list_areas])          
        @area_requesting_lists= RequestingList.find(:all, 
                                                    :conditions => ["requesting_list_areas.school_list_id = ? and (requesting_lists.course LIKE ? or book_lists.name LIKE ? or book_lists.author LIKE ? or book_lists.ISBN LIKE ?)",
                                                    SchoolList.find_by_english_name(@english_name).id,
                                                    "%#{@term}%", "%#{@term}%", 
                                                    "%#{@term}%", "%#{@term}%"],
                                                    :joins => [:book_list, :requesting_list_areas])
                                                       
        @area_lists=(@area_requesting_lists+@area_selling_lists).sort{|a,b| b.created_at <=> a.created_at }
        @area_lists=@area_lists.paginate(:per_page => 30, :page => params[:page])
        
        if request.xhr?
          sleep(3) # make request a little bit slower to see loader :-)
          render :partial => "layouts/showing_list_area", :collection => @area_lists    
        else       
          @area_lists    
        end                                                                  
      end        
    else
      redirect_to root_url
    end      
  end
  
  def allOutline
      if params[:search].blank?          
        @requesting_lists=RequestingList.all
        @selling_lists=SellingList.all      
        @lists=(@requesting_lists+@selling_lists).sort{|a,b| b.created_at <=> a.created_at }
        @lists=@lists.paginate(:per_page => 30, :page => params[:page])
        
        if request.xhr?
          sleep(3) # make request a little bit slower to see loader :-)
          render :partial => "layouts/showing_list", :collection => @lists    
        else       
          @lists    
        end
      else
        @term=params[:search][:term] 
        @search_c=true        
        @selling_lists= SellingList.find(:all, 
                                         :conditions => ["(selling_lists.course LIKE ? or book_lists.name LIKE ? or book_lists.author LIKE ? or book_lists.ISBN LIKE ?)",
                                          "%#{@term}%", "%#{@term}%", 
                                          "%#{@term}%", "%#{@term}%"],
                                          :joins => [:book_list])          
        @requesting_lists= RequestingList.find(:all, 
                                               :conditions => ["(requesting_lists.course LIKE ? or book_lists.name LIKE ? or book_lists.author LIKE ? or book_lists.ISBN LIKE ?)",
                                               "%#{@term}%", "%#{@term}%", 
                                               "%#{@term}%", "%#{@term}%"],
                                               :joins => [:book_list])
                                                       
        @lists=(@requesting_lists+@selling_lists).sort{|a,b| b.created_at <=> a.created_at }
        @lists=@lists.paginate(:per_page => 30, :page => params[:page])
        
        if request.xhr?
          sleep(3) # make request a little bit slower to see loader :-)
          render :partial => "layouts/showing_list", :collection => @lists    
        else       
          @lists    
        end                                                                  
      end         
  end
  	
  #=============================================================================================================for sell book
	def sellingPage1  
	  unless  params[:search].blank?
      @showing_requesting_lists=allList(params[:search][:name],"requesting") 
    else
      @showing_requesting_lists=allList(nil, "requesting") 
    end  

    if params[:selected_book_list_isbn].blank?      
      @selling_list=SellingList.new()                                        
    else  
      @book_list=BookList.find_by_ISBN(params[:selected_book_list_isbn])
      if @book_list.nil?
        if params[:selected_book_list_isbn]=="null"
          # solve google search return nil 
          i = 0;
          begin
            @google_book_list = GoogleBooks.search(params[:selected_book_list_name]).first  
             i +=1;
          end until i > 5 ||  @google_book_list!=nil
       
          if @google_book_list!=nil
            @book_list=BookList.new(:name=>@google_book_list.title,:author=>@google_book_list.authors,
                                    #:ISBN=>@google_book_list.isbn,:edition=>@google_book_list.edition,
                                    :language=>@google_book_list.language,:publisher=>@google_book_list.publisher,
                                    :image_name=>@google_book_list.image_link(:zoom=> 1),:is_google=>true )        
          end                        
        else   
          # solve google search return nil
          i = 0;
          begin
            @google_book_list = GoogleBooks.search('isbn:'+params[:selected_book_list_isbn]).first   
             i +=1;
          end until i > 5 ||  @google_book_list!=nil
          if @google_book_list!=nil  
            @book_list=BookList.new(:name=>@google_book_list.title,:author=>@google_book_list.authors,
                                    :ISBN=>@google_book_list.isbn,#:edition=>@google_book_list.edition,
                                    :language=>@google_book_list.language,:publisher=>@google_book_list.publisher,
                                    :image_name=>@google_book_list.image_link(:zoom=> 1),:is_google=>true )
            @book_list.save!                                                                                                      
          end
        end                
      else    #update book list form google books
         # solving google search returns nil
         i = 0;
         begin
            @google_book_list = GoogleBooks.search('isbn:'+@book_list.ISBN).first  
             i +=1;
         end until i > 3 ||  @google_book_list!=nil
         if !@google_book_list.nil?
          @book_list.update_attributes!(:name=>@google_book_list.title,:author=>@google_book_list.authors,
                                        :ISBN=>@google_book_list.isbn,#:edition=>@google_book_list.edition,
                                        :language=>@google_book_list.language,:publisher=>@google_book_list.publisher,
                                        :image_name=>@google_book_list.image_link(:zoom=> 1),:is_google=>true )
          @book_list.save!                                 
         end 
      end

      if @book_list 
        @selling_list=SellingList.new(:book_list_id=>@book_list.id,:name=>@book_list.name,:author=>@book_list.author,
                                      :ISBN=>@book_list.ISBN,:edition=>@book_list.edition,:language=>@book_list.language,
                                      :publisher=>@book_list.publisher,:image_name=>@book_list.image_name)
      else
        @selling_list=SellingList.new() 
      end    
    end 
    
    rescue ActiveRecord::RecordInvalid
      @book_list.valid?     
      @showing_requesting_lists=allList(nil, "requesting") 
      render :action=>:sellingPage1    
	end
	
	
	def sellingPage2
    @selling_list=SellingList.new(params[:selling_list]) 

    if !@selling_list.ISBN.blank?   
      @selling_list.ISBN=removeISBNDash(@selling_list.ISBN)
      @book_list=BookList.find_by_ISBN(@selling_list.ISBN)
      if @book_list.nil?
                 
         i = 0;
         begin
            @google_book_list = GoogleBooks.search('isbn:'+@selling_list.ISBN).first 
             i +=1;
         end until i > 2 ||  @google_book_list!=nil
               
         if @google_book_list     
            @book_list=BookList.new(:name=>@google_book_list.title,:author=>@google_book_list.authors,
                                    :ISBN=>@google_book_list.isbn,:edition=>@selling_list.edition,
                                    :language=>@google_book_list.language,:publisher=>@google_book_list.publisher,
                                    :image_name=>@google_book_list.image_link(:zoom=> 1),:is_google=>true )
         else                           
            @book_list=BookList.new(:name=>@selling_list.name,:author=>@selling_list.author,
                                    :ISBN=>@selling_list.ISBN,:edition=>@selling_list.edition,
                                    :language=>@selling_list.language,:publisher=>@selling_list.publisher,
                                    :image_name=>@selling_list.image_name)  
         end
      else
        if @book_list.is_google
          @book_list.update_attributes!(:edition=>@selling_list.edition)
        else
          @book_list.update_attributes!(:name=>@selling_list.name,:author=>@selling_list.author,
                                        :edition=>@selling_list.edition,:language=>@selling_list.language,
                                        :publisher=>@selling_list.publisher,:image_name=>@selling_list.image_name)      
        end             
      end
    else
      @book_list=BookList.new() 
    end                                   

      @book_list.save!
      @selling_list.book_list_id=@book_list.id                       
    ###############################for google chart
    if !@book_list.selling_lists.empty?     
      @chart_selling=google_chart_selling_list(@book_list)      
      @average_price=@book_list.selling_lists.average("price")
    end 
    
    
    rescue ActiveRecord::RecordInvalid      
      @book_list.valid?     
      @showing_requesting_lists=allList(nil, "requesting") 
      render :action=>:sellingPage1   
  end
	
	def sellingPage3Save 
 
    @selling_list=SellingList.new(params[:selling_list]) 
     
    params[:area].each_with_index do |value, index|
      if !params[:area][index.to_s].blank?
        @selling_list.selling_list_areas<<SellingListArea.new(:school_list_id=>params[:area][index.to_s], :location=>params[:location][index.to_s])
      end
    end
     
    @selling_list.user_id=session[:user_id]  
    @book_list=BookList.find(@selling_list.book_list_id)
      

    ###############################for post pic on FB wall
    if !@selling_list.photo_source.blank?
      current_user.profile.photo!( :source => @selling_list.photo_source, :message =>"賣 "+@book_list.name+" $"+@selling_list.price.to_s+"元")
    end
    
    @selling_list.save!
    @book_list.selling_lists<<@selling_list  
    @book_list.save!
    
    session[:temp_selling_list]=nil 
    ###############################send notification mails
    @book_list.requesting_lists.each do |requesting_list|
      if requesting_list.user.user_config.sys_selling_email and requesting_list.available
        SystemMailer.send_notification(@selling_list, requesting_list, "requesting").deliver
      end  
    end
  
  
  
    redirect_to "/my_selling/"+@selling_list.id.to_s , notice: '儲存成功!'  
    rescue ActiveRecord::RecordInvalid     
      if !@selling_list.valid?  
        session[:temp_selling_list]=params[:selling_list]        
        render :action=>:sellingPage2 
      elsif !@book_list.valid? 
        @showing_requesting_lists=allList(nil, "requesting") 
        render :action=>:sellingPage1
      end   
  end
   
	#=============================================================================================================for request book
  def requestingPage1
    unless  params[:search].blank?
      @showing_selling_lists=allList(params[:search][:name], "selling") 
    else
      @showing_selling_lists=allList(nil, "selling") 
    end  
    
    if params[:selected_book_list_isbn].blank?      
      @requesting_list=RequestingList.new()                                        
    else  
      @book_list=BookList.find_by_ISBN(params[:selected_book_list_isbn])
      if @book_list.nil?
        if params[:selected_book_list_isbn]=="null"
          # solve google search return nil 
          i = 0;
          begin
            @google_book_list = GoogleBooks.search(params[:selected_book_list_name]).first  
             i +=1;
          end until i > 5 ||  @google_book_list!=nil
       
          if @google_book_list!=nil
            @book_list=BookList.new(:name=>@google_book_list.title,:author=>@google_book_list.authors,
                                    #:ISBN=>@google_book_list.isbn,:edition=>@google_book_list.edition,
                                    :language=>@google_book_list.language,:publisher=>@google_book_list.publisher,
                                    :image_name=>@google_book_list.image_link(:zoom=> 1),:is_google=>true )        
          end                        
        else   
          # solve google search return nil
          i = 0;
          begin
            @google_book_list = GoogleBooks.search('isbn:'+params[:selected_book_list_isbn]).first   
             i +=1;
          end until i > 5 ||  @google_book_list!=nil
          if @google_book_list!=nil  
            @book_list=BookList.new(:name=>@google_book_list.title,:author=>@google_book_list.authors,
                                    :ISBN=>@google_book_list.isbn,#:edition=>@google_book_list.edition,
                                    :language=>@google_book_list.language,:publisher=>@google_book_list.publisher,
                                    :image_name=>@google_book_list.image_link(:zoom=> 1),:is_google=>true )
            @book_list.save!                                                                                                      
          end
        end                
      else    #update book list form google books
         # solving google search returns nil
         i = 0;
         begin
            @google_book_list = GoogleBooks.search('isbn:'+@book_list.ISBN).first  
             i +=1;
         end until i > 3 ||  @google_book_list!=nil
         if !@google_book_list.nil?
          @book_list.update_attributes!(:name=>@google_book_list.title,:author=>@google_book_list.authors,
                                        :ISBN=>@google_book_list.isbn,#:edition=>@google_book_list.edition,
                                        :language=>@google_book_list.language,:publisher=>@google_book_list.publisher,
                                        :image_name=>@google_book_list.image_link(:zoom=> 1),:is_google=>true )
          @book_list.save!                                 
         end 
      end

      if @book_list 
        @requesting_list=RequestingList.new(:book_list_id=>@book_list.id,:name=>@book_list.name,:author=>@book_list.author,
                                            :ISBN=>@book_list.ISBN,:edition=>@book_list.edition,:language=>@book_list.language,
                                            :publisher=>@book_list.publisher,:image_name=>@book_list.image_name)
      else
        @requesting_list=RequestingList.new() 
      end    
    end 
    
    rescue ActiveRecord::RecordInvalid
      @book_list.valid?     
      @showing_selling_lists=allList(nil, "selling") 
      render :action=>:requestingingPage1       
  end
  
  def requestingPage2  
    @requesting_list=RequestingList.new(params[:requesting_list])
    if !@requesting_list.ISBN.blank?  
      @requesting_list.ISBN=removeISBNDash(@requesting_list.ISBN) 
      @book_list=BookList.find_by_ISBN(@requesting_list.ISBN)
      if @book_list.nil?  
         i = 0;
         begin
            @google_book_list = GoogleBooks.search('isbn:'+@requesting_list.ISBN).first
             i +=1;
         end until i > 2 ||  @google_book_list!=nil
         if @google_book_list     
            @book_list=BookList.new(:name=>@google_book_list.title,:author=>@google_book_list.authors,
                                    :ISBN=>@google_book_list.isbn,:edition=>@requesting_list.edition,
                                    :language=>@google_book_list.language,:publisher=>@google_book_list.publisher,
                                    :image_name=>@google_book_list.image_link(:zoom=> 1),:is_google=>true )
         else                           
            @book_list=BookList.new(:name=>@requesting_list.name,:author=>@requesting_list.author,
                                    :ISBN=>@requesting_list.ISBN,:edition=>@requesting_list.edition,
                                    :language=>@requesting_list.language,:publisher=>@requesting_list.publisher,
                                    :image_name=>@requesting_list.image_name)  
         end
      else
        if @book_list.is_google
          @book_list.update_attributes!(:edition=>@requesting_list.edition)
        else
          @book_list.update_attributes!(:name=>@requesting_list.name,:author=>@requesting_list.author,
                                        :edition=>@requesting_list.edition,:language=>@requesting_list.language,
                                        :publisher=>@requesting_list.publisher,:image_name=>@requesting_list.image_name)      
        end             
      end
    else
      @book_list=BookList.new() 
    end     
    
    @book_list.save!
    @requesting_list.book_list_id=@book_list.id                      
   
    rescue ActiveRecord::RecordInvalid      
      @book_list.valid?     
      @showing_selling_lists=allList(nil, "selling") 
      render :action=>:requestingPage1     
  end
  
  def requestingPage3Save
     
    @requesting_list=RequestingList.new(params[:requesting_list]) 
    params[:area].each_with_index do |value, index|
      if !params[:area][index.to_s].blank?
        @requesting_list.requesting_list_areas<<RequestingListArea.new(:school_list_id=>params[:area][index.to_s], :location=>params[:location][index.to_s])
      end
    end
    @requesting_list.user_id=session[:user_id]  
    @book_list=BookList.find(@requesting_list.book_list_id)
      
    
    @requesting_list.save!
    @book_list.requesting_lists<<@requesting_list  
    @book_list.save!
    
    
    session[:temp_requesting_list]=nil 
    ###############################send notification mails
    @book_list.selling_lists.each do |selling_list|
      if selling_list.user.user_config.sys_requesting_email and selling_list.available
        SystemMailer.send_notification(@requesting_list, selling_list, "selling").deliver
      end  
    end  
       
    redirect_to :controller => 'my_requesting', :action => 'show', :id=>@requesting_list.id, notice: '儲存成功!'
    
    rescue ActiveRecord::RecordInvalid
      
     
      
      if !@requesting_list.valid?    
        session[:temp_requesting_list]=params[:requesting_list]        
        render :action=>:requestingPage2 
      elsif !@book_list.valid? 
        @showing_selling_lists=allList(nil, "selling") 
        render :action=>:requestingPage1
      end    
  end
    
  #=============================================================================================================for my & friends book lists

  def friendsBookLists
     fds=current_user.profile.friends
     @friends=Array.new
     fds.each do |fd|
      user=User.find_by_FB_identifier(fd.identifier)
        if !user.nil?
            @friends<<user
        end
     end
  end
  
  def myBookLists
    @user=User.find(session[:user_id])
    @my_selling_lists = @user.selling_lists.find(:all, :order => "available DESC, created_at DESC")
    @my_requesting_lists = @user.requesting_lists.find(:all, :order => "available DESC, created_at DESC")
  end
  
  #=============================================================================================================for posting FB wall    
  def post_on_fb
    if !params[:selling_list_id].blank?
      @selling_list=SellingList.find(params[:selling_list_id])  
      #@requesting_lists=@selling_list.book_list.requesting_lists
    
      current_user.profile.feed!(
        :picture => @selling_list.book_list.image_name,
        :message =>"賣 \""+@selling_list.book_list.name+"\" $"+@selling_list.price.to_s, 
        :description => '校園面交平台',
        :link =>dns_name+"/main/showSellingBook?id="+@selling_list.id.to_s   
      )
    
      redirect_to "/my_selling/"+@selling_list.id.to_s , notice: '已張貼在FB塗鴉牆上!'
    elsif !params[:requesting_list_id].blank?
      @requesting_list=RequestingList.find(params[:requesting_list_id])  
      #@selling_lists=@requesting_list.book_list.selling_lists
    
      current_user.profile.feed!(
        :picture => @requesting_list.book_list.image_name,
        :message =>"徵求 \""+@requesting_list.book_list.name+"\" 預算 $"+@requesting_list.prefer_price_from.to_s+"~$"+@requesting_list.prefer_price_to.to_s,
        :description =>  '校園面交平台',
        :link =>dns_name+"/main/showRequestingBook?id="+@requesting_list.id.to_s
      )
    
      redirect_to "/my_requesting/"+@requesting_list.id.to_s , notice: "已張貼在FB塗鴉牆上!"     
    end     
  end
  
  def fbCommentNotification
    if !params[:selling_list_id].blank?
      @selling_list=SellingList.find(params[:selling_list_id])  
      if params[:user]!=User.find(@selling_list.user_id).FB_identifier
        SystemMailer.sendFBCommentNotification(@selling_list, "selling", params[:user], params[:comment]).deliver  
      end  
      render :nothing => true
    elsif !params[:requesting_list_id].blank?
      @requesting_list=RequestingList.find(params[:requesting_list_id])  
      if params[:user]!=User.find(@requesting_list.user_id).FB_identifier
        SystemMailer.sendFBCommentNotification(@requesting_list, "requesting", params[:user], params[:comment]).deliver  
      end  
      render :nothing => true  
    end     
  end
  
  #=============================================================================================================for showing list  
  def areaListShowing
    if !params[:type].blank?  
      @english_name=params['english_name']
      @chinese_name=SchoolList.find_by_english_name(@english_name).chinese_name
      @search_c=false
      if params[:type]=="selling"   
        @area_selling_lists = SellingList.joins(:selling_list_areas).where('selling_list_areas.school_list_id = ?', SchoolList.find_by_english_name(@english_name)).paginate(:per_page => 30, :page => params[:page]).order('created_at DESC')   
        #@type="selling"
        if request.xhr?
          sleep(3) # make request a little bit slower to see loader :-)
          render :partial => "layouts/showing_selling_list_area_mas", :collection => @area_selling_lists
        else       
          @area_selling_lists
        end    
      elsif params[:type]=="requesting"
        @area_requesting_lists = RequestingList.joins(:requesting_list_areas).where('requesting_list_areas.school_list_id = ?', SchoolList.find_by_english_name(@english_name)).paginate(:per_page => 30, :page => params[:page]).order('created_at DESC')   
        #@type="requesting"
        if request.xhr?
          sleep(3) # make request a little bit slower to see loader :-)
          render :partial => "layouts/showing_requesting_list_area_mas", :collection => @area_requesting_lists
        else       
          @area_requesting_lists
        end  
      end
    else
      @english_name=params[:search][:english_name]
      @chinese_name=SchoolList.find_by_english_name(@english_name).chinese_name
      @search_c=true
      if params[:search][:type]=="selling"  #for selling lists searching
        @term=params[:search][:selling_name]            
        @area_selling_lists= SellingList.paginate(:per_page => 30, :page => params[:page], 
                                                 :conditions => ["selling_list_areas.school_list_id = ? and (selling_lists.course LIKE ? or book_lists.name LIKE ? or book_lists.author LIKE ? or book_lists.ISBN LIKE ?)",
                                                 SchoolList.find_by_english_name(@english_name).id,
                                                 "%#{params[:search][:selling_name]}%", "%#{params[:search][:selling_name]}%", 
                                                 "%#{params[:search][:selling_name]}%", "%#{params[:search][:selling_name]}%"],
                                                 :joins => [:book_list, :selling_list_areas])      
        if request.xhr?
          sleep(3) # make request a little bit slower to see loader :-)
          render :partial => "layouts/showing_selling_list_area_mas", :collection => @area_selling_lists
        else       
          @area_selling_lists
        end       
      elsif params[:search][:type]=="requesting"  
        @term=params[:search][:requesting_name]          
        @area_requesting_lists= RequestingList.paginate(:per_page => 30, :page => params[:page], 
                                                       :conditions => ["requesting_list_areas.school_list_id = ? and (requesting_lists.course LIKE ? or book_lists.name LIKE ? or book_lists.author LIKE ? or book_lists.ISBN LIKE ?)",
                                                       SchoolList.find_by_english_name(@english_name).id,
                                                       "%#{params[:search][:requesting_name]}%", "%#{params[:search][:requesting_name]}%", 
                                                       "%#{params[:search][:requesting_name]}%", "%#{params[:search][:requesting_name]}%"],
                                                       :joins => [:book_list, :requesting_list_areas])
        if request.xhr?
          sleep(3) # make request a little bit slower to see loader :-)
          render :partial => "layouts/showing_requesting_list_area_mas", :collection => @area_requesting_lists
        else       
          @area_requesting_lists
        end                                                             
      end     
    end        
  end

  def allListShowing
    if !params[:type].blank?  
      @search_c=false
      if params[:type]=="selling"   
        @selling_lists = SellingList.paginate(:per_page => 30, :page => params[:page]).order('created_at DESC')   
        if request.xhr?
          sleep(3) # make request a little bit slower to see loader :-)
          render :partial => "layouts/showing_selling_list_mas", :collection => @selling_lists
        else       
          @selling_lists
        end    
      elsif params[:type]=="requesting"
        @requesting_lists = RequestingList.paginate(:per_page => 30, :page => params[:page]).order('created_at DESC')   
        if request.xhr?
          sleep(3) # make request a little bit slower to see loader :-)
          render :partial => "layouts/showing_requesting_list_mas", :collection => @requesting_lists
        else       
          @requesting_lists
        end  
      end
    else
      @search_c=true
      if params[:search][:type]=="selling"  #for selling lists searching
        @term=params[:search][:selling_name]            
        @selling_lists= SellingList.paginate(:per_page => 30, :page => params[:page], 
                                             :conditions => ["(selling_lists.course LIKE ? or book_lists.name LIKE ? or book_lists.author LIKE ? or book_lists.ISBN LIKE ?)",
                                                 "%#{params[:search][:selling_name]}%", "%#{params[:search][:selling_name]}%", 
                                                 "%#{params[:search][:selling_name]}%", "%#{params[:search][:selling_name]}%"],
                                                 :joins => [:book_list])      
        if request.xhr?
          sleep(3) # make request a little bit slower to see loader :-)
          render :partial => "layouts/showing_selling_list_mas", :collection => @selling_lists
        else       
          @selling_lists
        end       
      elsif params[:search][:type]=="requesting"  
        @term=params[:search][:requesting_name]          
        @requesting_lists= RequestingList.paginate(:per_page => 30, :page => params[:page], 
                                                   :conditions => ["(requesting_lists.course LIKE ? or book_lists.name LIKE ? or book_lists.author LIKE ? or book_lists.ISBN LIKE ?)",
                                                   "%#{params[:search][:requesting_name]}%", "%#{params[:search][:requesting_name]}%", 
                                                   "%#{params[:search][:requesting_name]}%", "%#{params[:search][:requesting_name]}%"],
                                                   :joins => [:book_list, :requesting_list_areas])
        if request.xhr?
          sleep(3) # make request a little bit slower to see loader :-)
          render :partial => "layouts/showing_requesting_list_mas", :collection => @requesting_lists
        else       
          @requesting_lists
        end                                                             
      end     
    end                              
  end
  
  def showRequestingBook
    @requesting_list = RequestingList.find(params[:id])
  end

  def showSellingBook
    @selling_list = SellingList.find(params[:id])
  end
  
  #=============================================================================================================for auto complete
  def auto_complete_for_book_list_name
  
    @booklists_json=Array.new
    @booklists=BookList.find(:all, :conditions => ["name LIKE ? AND is_google= ? ", "%#{params[:term]}%", false])
    @booklists.each do |book|
      if book.image_name.blank?    
        img_link="/assets/NoImg.png"
      else
        img_link=book.image_name
      end     
      @booklists_json << 
      {
        :label =>book.name+"  作者:"+book.author,
        :isbn  =>book.ISBN,
        :value =>book.name,
        :link  =>img_link,
        :is_google=>false
      }
    end     
    @booklists_google= GoogleBooks.search(params[:term], {:count => 7})     
    @booklists_google.each do |book|
      if book.image_link(:zoom=> 5)   
        img_link=book.image_link(:zoom=> 5)
      else
        img_link="/assets/NoImg.png"
      end  
      @booklists_json << 
      {
        :label =>book.title+"  作者:"+book.authors,
        :isbn  =>book.isbn,
        :value =>book.title,
        :link  =>img_link,
        :is_google=>true
      }
    end 
    render :json=>@booklists_json.to_json 
  end
  
  def auto_complete_for_book_list_isbn
    params[:term]=removeISBNDash(params[:term]) 
    @booklists_json=Array.new
    @booklists=BookList.find(:all, :conditions => ["ISBN LIKE ? AND is_google= ? ", "%#{params[:term]}%", false])
    @booklists.each do |book|
      if book.image_name.blank?    
        img_link="/assets/NoImg.png"
      else
        img_link=book.image_name
      end     
      @booklists_json << 
      {
        :label =>book.name+"/"+book.ISBN,
        :isbn  =>book.ISBN,
        :value =>book.ISBN,
        :link  =>img_link,
        :is_google=>false
      }
    end    
    @booklists_google= GoogleBooks.search('isbn:'+params[:term], {:count => 7})    
    @booklists_google.each do |book|
      if book.image_link(:zoom=> 5)   
        img_link=book.image_link(:zoom=> 5)
      else
        img_link="/assets/NoImg.png"
      end      
      @booklists_json << 
      {
        :label =>book.isbn+"/"+book.title,
        :isbn  =>book.isbn,
        :value =>book.isbn,
        :link  =>img_link,
        :is_google=>true
      }
    end 
    render :json=>@booklists_json.to_json 
  end  
  
  def auto_complete_for_book_list_author
    
    @booklists_json=Array.new 
    @booklists=BookList.find(:all, :conditions => ["author LIKE ? AND is_google= ? ", "%#{params[:term]}%", false])
    @booklists.each do |book|
      if book.image_name.blank?    
        img_link="/assets/NoImg.png"
      else
        img_link=book.image_name
      end
      @booklists_json << 
      {
        :label =>book.name+"  作者:"+book.author,
        :isbn  =>book.ISBN,
        :value =>book.name,
        :link  =>img_link,
        :is_google=>false
      }
    end 
    @booklists_google= GoogleBooks.search('inauthor:'+params[:term], {:count => 7}) 
    @booklists_google.each do |book|
      if book.image_link(:zoom=> 5)   
        img_link=book.image_link(:zoom=> 5)
      else
        img_link="/assets/NoImg.png"
      end  
      @booklists_json << 
      {
        :label =>book.title+"  作者:"+book.authors,
        :isbn  =>book.isbn,
        :value =>book.title,
        :link  =>img_link,
        :is_google=>true
      }
    end      
    render :json=>@booklists_json.to_json 
  end 
  
  def auto_complete_for_SearchBookList
    @booklists_json=Array.new
    @booklists=BookList.find(:all, :conditions => ["name LIKE ? or author LIKE ? or ISBN LIKE ?", "%#{params[:term]}%", "%#{params[:term]}%", "%#{params[:term]}%"])
    @booklists.each do |book|
      if book.image_name.blank?    
        img_link="/assets/NoImg.png"
      else
        img_link=book.image_name
      end    
      @booklists_json << 
      {
        :label =>book.name+"  作者:"+book.author+"("+book.ISBN+")",
        :id    =>book.id,
        :value =>book.name,
        :link  =>img_link,
      }
    end 
     
    render :json=>@booklists_json.to_json 
  end  
  #=============================================================================================================for others 
  def sendMessagejs
    if !params[:sended_selling_list_id].blank?
      @sended_selling_list=true;
      @list = SellingList.find(params[:sended_selling_list_id])
      @sended_user=@list.user
    elsif !params[:sended_requesting_list_id].blank?
      @sended_requesting_list=true;
      @list =RequestingList.find(params[:sended_requesting_list_id])
      @sended_user=@list.user     
    end     
    respond_to do |format|
        format.js 
    end    
  end  
  
  def allList(term=nil, type=nil )
    if type!=nil
      if type=="selling"    
        if term!=nil          #for selling lists searching
          @book_lists = BookList.find(:all, :conditions => ['name LIKE ?', "%#{term}%"])
          @showing_selling_lists=Array.new
          @book_lists.each do |b|       
             b.selling_lists.each do |s|
              @showing_selling_lists<<s
             end
          end      
          @showing_selling_lists
        else
          @showing_selling_lists = SellingList.paginate(:per_page => 10, :page => params[:page]).order('created_at DESC')
        end     
      elsif  type=="requesting" 
        if term!=nil            #for requesting lists searching
          @book_lists = BookList.find(:all, :conditions => ['name LIKE ?', "%#{term}%"])
          @showing_requesting_lists=Array.new
          @book_lists.each do |b|       
            b.requesting_lists.each do |s|
              @showing_requesting_lists<<s
            end
          end      
          @showing_requesting_lists
        else
          @showing_requesting_lists = RequestingList.paginate(:per_page => 10, :page => params[:page]).order('created_at DESC')     
        end 
      end             
    else #for pageless 
      if params['type']=="selling"
        @showing_selling_lists = SellingList.paginate(:per_page => 10, :page => params[:page]).order('created_at DESC')
        sleep(3) # make request a little bit slower to see loader :-)
        render :partial => "layouts/showing_selling_list", :collection => @showing_selling_lists 
      elsif params['type']=="requesting"
        @showing_requesting_lists = RequestingList.paginate(:per_page => 10, :page => params[:page]).order('created_at DESC')
        sleep(3) # make request a little bit slower to see loader :-)
        render :partial => "layouts/showing_requesting_list", :collection => @showing_requesting_lists       
      end   
    end    
  end  
  
  def zxing
    directory = "public/images/upload"
    path = File.join(directory, 'zxing')    
    File.open(path, 'wb') do |f|
      f.write(Base64.decode64(params[:image]))
    end
    res=ZXing.decode path
    render :json => {:isbn => res}.to_json  
  end  
  
  
protected
  def removeISBNDash(input)
    input.gsub('-', '')
  end  
  
 
end
