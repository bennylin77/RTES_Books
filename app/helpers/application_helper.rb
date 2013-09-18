# encoding: UTF-8
module ApplicationHelper
  include Authen::HelperMethods
  
  def dns_name
     'http://rtes.tw'
  end
  #for page scrolling
  def pageless(total_pages, url=nil, container=nil)
    opts = {
      :totalPages => total_pages,
      :url        => url,
      :loaderImage => image_path("loading.gif")
    }
    
    container && opts[:container] ||= container
    
    javascript_tag("$('#sidebar').pageless(#{opts.to_json});")
  end
=begin 
  #for area page scrolling
  def areaPageless(total_pages, url=nil, container=nil)
    opts = {
      :totalPages => total_pages,
      :url        => url,
      :loaderMsg  => '正在讀取更多資料',
      :loaderImage => image_path("loading.gif")
    }
    
    container && opts[:container] ||= container
    
    javascript_tag("$('#main').pageless(#{opts.to_json});")
  end  
=end  
  
  def findFacebookIDByUserID(userID)
    User.find(userID).FB_identifier
  end
  
  def languageTranslator(string)
    if string=="en"
      "英文"  
    elsif string=="zh-TW"
      "正體"
    elsif string=="zh-CN"
      "簡体"
    else
      "其它"  
    end
  end
  
  def levelConverter (string, type) 
    if type=="r"
      if string=="none"
        "不接受"
      elsif string=="less"
        "少量"  
      elsif string=="mid"
        "中等"  
      elsif string=="mass"
        "多量"
      else
        "--"        
      end
    elsif type=="s"
      if string=="none"
        "無"
      elsif string=="less"
        "少量"  
      elsif string=="mid"
        "中等"  
      elsif string=="mass"
        "多量"
      else
        "--"         
      end
    end       
  end
  
  def YNConverter (string) 
    if string=="Y"
      "是"
    elsif string=="N"
      "否"
    else
      "--"       
    end     
  end 
  
  def schoolOptions(type)
    if type=="selling"
      options = Hash.new 
      SchoolList.all.each do |s|  
        if s.verified
          if !s.chinese_name.blank? 
            options[s.chinese_name+' (線上賣書數 '+SellingList.joins(:selling_list_areas).where('selling_list_areas.school_list_id = ?', s).count.to_s+'本)']=s.english_name
          else
            options[s.english_name+' (線上賣書數 '+SellingList.joins(:selling_list_areas).where('selling_list_areas.school_list_id = ?', s).count.to_s+'本)']=s.english_name
          end
        end   
      end
    elsif type=="requesting"
      options = Hash.new 
      SchoolList.all.each do |s|
        if s.verified  
          if !s.chinese_name.blank? 
            options[s.chinese_name+' (線上徵書數 '+RequestingList.joins(:requesting_list_areas).where('requesting_list_areas.school_list_id = ?', s).count.to_s+'本)']=s.english_name 
          else
            options[s.english_name+' (線上徵書數 '+RequestingList.joins(:requesting_list_areas).where('requesting_list_areas.school_list_id = ?', s).count.to_s+'本)']=s.english_name
          end
        end   
      end
    elsif type=="both"
      options = Hash.new 
      SchoolList.all.each do |s|
        if s.verified  
          if !s.chinese_name.blank? 
            options[s.chinese_name+' (線上書本數 '+(SellingList.joins(:selling_list_areas).where('selling_list_areas.school_list_id = ?', s).count+RequestingList.joins(:requesting_list_areas).where('requesting_list_areas.school_list_id = ?', s).count).to_s+'本)']=s.english_name 
          else
            options[s.english_name+' (線上書本數 '+(SellingList.joins(:selling_list_areas).where('selling_list_areas.school_list_id = ?', s).count+RequestingList.joins(:requesting_list_areas).where('requesting_list_areas.school_list_id = ?', s).count).to_s+'本)']=s.english_name
          end 
        end
      end        
    end       
    options
  end
  
  def schoolOptionsId(type)
    if type=="selling"
      options = Hash.new 
      SchoolList.all.each do |s| 
        if s.verified  
          if !s.chinese_name.blank? 
            options[s.chinese_name+' (線上賣書數 '+SellingList.joins(:selling_list_areas).where('selling_list_areas.school_list_id = ?', s).count.to_s+'本)']=s.id
          else
            options[s.english_name+' (線上賣書數 '+SellingList.joins(:selling_list_areas).where('selling_list_areas.school_list_id = ?', s).count.to_s+'本)']=s.id
          end
        end 
      end
    elsif type=="requesting"
      options = Hash.new 
      SchoolList.all.each do |s|
        if s.verified   
          if !s.chinese_name.blank? 
            options[s.chinese_name+' (線上徵書數 '+RequestingList.joins(:requesting_list_areas).where('requesting_list_areas.school_list_id = ?', s).count.to_s+'本)']=s.id 
          else
            options[s.english_name+' (線上徵書數 '+RequestingList.joins(:requesting_list_areas).where('requesting_list_areas.school_list_id = ?', s).count.to_s+'本)']=s.id
          end
        end 
      end
    elsif type=="both"
      options = Hash.new 
      SchoolList.all.each do |s|
        if s.verified   
          if !s.chinese_name.blank? 
            options[s.chinese_name+' (線上書本數 '+(SellingList.joins(:selling_list_areas).where('selling_list_areas.school_list_id = ?', s).count+RequestingList.joins(:requesting_list_areas).where('requesting_list_areas.school_list_id = ?', s).count).to_s+'本)']=s.id
          else
            options[s.english_name+' (線上書本數 '+(SellingList.joins(:selling_list_areas).where('selling_list_areas.school_list_id = ?', s).count+RequestingList.joins(:requesting_list_areas).where('requesting_list_areas.school_list_id = ?', s).count).to_s+'本)']=s.id
          end
        end     
      end        
    end       
    options
  end

  
  
  def showingListArea(type=nil, list=nil)
    result=Array.new
    if type=='selling'      
      list.selling_list_areas.each do |e|    
        if !SchoolList.find(e.school_list_id).chinese_name.blank?
          result<<SchoolList.find(e.school_list_id).chinese_name
        else
          result<<SchoolList.find(e.school_list_id).english_name
        end
      end    
    elsif type=='requesting'
      list.requesting_list_areas.each do |e|    
        if !SchoolList.find(e.school_list_id).chinese_name.blank?
          result<<SchoolList.find(e.school_list_id).chinese_name
        else
          result<<SchoolList.find(e.school_list_id).english_name
        end
      end                 
    end  
    if result.count==0
      result_string='--'         
    else
      result_string=result.join("<br>")
    end
    result_string             
  end
  
  def showingListLocation(type=nil, list=nil, name=nil)
    result=Array.new
    if type=='selling'      
      list.selling_list_areas.each do |e|    
        if SchoolList.find(e.school_list_id).english_name==name
          if !e.location.blank?
            result<<e.location
          end
        end
      end    
    elsif type=='requesting'
      list.requesting_list_areas.each do |e|    
        if SchoolList.find(e.school_list_id).english_name==name
          if !e.location.blank?
            result<<e.location
          end
        end
      end                 
    end
    if result.count==0
      result_string='--'         
    else
      result_string=result.join('<br>')
    end
    result_string 
  end  
  
  def showingListAreaAndLocation(type=nil, list=nil)
    result=Array.new
    if type=='selling'      
      list.selling_list_areas.each do |e|    
        if !SchoolList.find(e.school_list_id).blank?
          if !SchoolList.find(e.school_list_id).chinese_name.blank?
            result<<SchoolList.find(e.school_list_id).chinese_name+"-"+locationShowing(e.location)
          else
            result<<SchoolList.find(e.school_list_id).english_name+"-"+locationShowing(e.location)
          end
        else
          result<<SchoolList.find(e.school_list_id).english_name+"-"+locationShowing(e.location)
        end
      end    
    elsif type=='requesting'
      list.requesting_list_areas.each do |e|    
        if !SchoolList.find(e.school_list_id).blank?
          if !SchoolList.find(e.school_list_id).chinese_name.blank?
            result<<SchoolList.find(e.school_list_id).chinese_name+"-"+locationShowing(e.location)
          else
            result<<SchoolList.find(e.school_list_id).english_name+"-"+locationShowing(e.location)
          end
        else
          result<<SchoolList.find(e.school_list_id).english_name+"-"+locationShowing(e.location)
        end
      end                 
    end         
    if result.count==0
      result_string='--'         
    else
      result_string=result.join(', ')
    end
    result_string 
  end
  
  private
  
  def locationShowing(location=nil)
    if location.blank?
      '無詳細地點'
    else
      location    
    end   
  end
  
  def dayAdd(date=nil ,day=nil)
     date+day*(60 * 60 * 24) 
  end   
end
