module Authen

  class Unauthorized < StandardError; end

  def self.included(base)
    base.send(:include, Authen::HelperMethods)
    base.send(:include, Authen::ControllerMethods)
  end

  module HelperMethods

    def current_user
      @current_user ||= Facebook.find_by_identifier(User.find(session[:user_id]).FB_identifier )
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def authenticated?
      !current_user.blank?
    end

  end

  module ControllerMethods

    def require_authentication
      authenticate User.find_by_id( session[:user_id] )
    rescue Unauthorized => e
      redirect_to root_url and return false
    end

    def authenticate(user)
      raise Unauthorized unless user
      session[:user_id] = user.id
    end

    def unauthenticate
      current_user.destroy
      @current_user = session[:user_id] = nil
    end

  end

end