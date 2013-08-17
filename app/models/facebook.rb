class Facebook < ActiveRecord::Base
  has_many :subscriptions

  def profile
    @profile ||= FbGraph::User.me(self.access_token).fetch
  end

  class << self
    extend ActiveSupport::Memoizable

    def config
      @config ||= if ENV['fb_client_id'] && ENV['fb_client_secret'] && ENV['fb_scope'] && ENV['fb_canvas_url']
        {
          :client_id     => ENV['fb_client_id'],
          :client_secret => ENV['fb_client_secret'],
          :scope         => ENV['fb_scope'],
          :canvas_url    => ENV['fb_canvas_url']
        }
      else
        YAML.load_file("#{Rails.root}/config/facebook.yml")[Rails.env].symbolize_keys
      end
    rescue Errno::ENOENT => e
      raise StandardError.new("config/facebook.yml could not be loaded.")
    end

    def app
      FbGraph::Application.new config[:client_id], :secret => config[:client_secret]
    end

    def auth(redirect_uri = nil)
      FbGraph::Auth.new config[:client_id], config[:client_secret], :redirect_uri => redirect_uri
    end

    def identify(fb_user)
      _fb_user_ = find_or_initialize_by_identifier(fb_user.identifier.try(:to_s))
      user=User.find_or_initialize_by_FB_identifier(fb_user.identifier.try(:to_s)) #for user     
      _fb_user_.access_token = fb_user.access_token.access_token       
      _fb_user_.save!
      current_user=_fb_user_.profile
      user.email=current_user.email                                                #save email 
      if user.FB_username.blank?                                                   #save username
        user.FB_username=current_user.username  
      end  
      user.educations.destroy_all
      user.save! #save user first to get user id
      
      if user.user_menu_lists.count==0
        if current_user.education
          current_user.education.each do |e|
            if e.type=="College" or e.type=="Graduate School"
              school_list=SchoolList.find_by_english_name(e.school.name)
              if school_list.nil?
                school_list=SchoolList.new(:english_name=>e.school.name)
                school_list.save!
              end   
              user.educations<<Education.new(:school_list_id=>school_list.id, :degree=>e.type)
              if UserMenuList.where("user_id= ? AND school_list_id= ?", user.id, school_list.id).count==0    
                user.user_menu_lists<<UserMenuList.new(:school_list_id=>school_list.id)
              end  
            end 
            user.save!  #save user second             
          end   
        end
      else    
        if current_user.education
          current_user.education.each do |e|
            if e.type=="College" or e.type=="Graduate School"
              school_list=SchoolList.find_by_english_name(e.school.name)
              if school_list.nil?
                school_list=SchoolList.new(:english_name=>e.school.name)
                school_list.save!
              end   
              user.educations<<Education.new(:school_list_id=>school_list.id, :degree=>e.type)
            end               
          end   
        end
        user.save!  #save user second
      end 
      
      if user.user_config.nil?
        if Education.where("user_id = ? ", user.id).count!=0
          grad=Education.where("user_id = ? AND degree = ? ", user.id, "Graduate School")
          colle=Education.where("user_id = ? AND degree = ? ", user.id, "College")
          if grad.count!=0
            user.user_config=UserConfig.new(:default_trading_school=>grad.first.school_list_id, :default_index=>grad.first.school_list_id) 
            user.user_config.save!
          elsif colle.count!=0
            user.user_config=UserConfig.new(:default_trading_school=>colle.first.school_list_id, :default_index=>colle.first.school_list_id) 
            user.user_config.save!       
          end
        end        
        user.save!  #save user third
      end        
      _fb_user_  #return 
    end
  end

end
