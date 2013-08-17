class UserConfigsController < ApplicationController
  
  before_filter :checkUserLogin
  before_filter :checkUser
  def show
    @user_config = UserConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_config }
    end
  end

  def new
    @user_config = UserConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_config }
    end
  end

  def edit
    @user_config = UserConfig.find(params[:id])
    @user_menu_lists = User.find(session[:user_id]).user_menu_lists
  end

  def create
    @user_config = UserConfig.new(params[:user_config])

    respond_to do |format|
      if @user_config.save
        format.html { redirect_to @user_config, notice: 'User config was successfully created.' }
        format.json { render json: @user_config, status: :created, location: @user_config }
      else
        format.html { render action: "new" }
        format.json { render json: @user_config.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user_config = UserConfig.find(params[:id])
    @user=User.find(session[:user_id])
    @user.user_menu_lists.destroy_all
    params[:area].each_with_index do |value, index|
      if !params[:area][index.to_s].blank?
       @user.user_menu_lists<<UserMenuList.new(:school_list_id=>params[:area][index.to_s])
      end
    end
    @user.save!

    if @user_config.update_attributes(params[:user_config])
      redirect_to root_url
    else
      format.html { render action: "edit" }
    end
  end
  
  def destroy
    @user_config = UserConfig.find(params[:id])
    @user_config.destroy

    respond_to do |format|
      format.html { redirect_to user_configs_url }
      format.json { head :no_content }
    end
  end
  
protected
  def checkUser
    if UserConfig.find(params[:id]).user_id!=session[:user_id]
      redirect_to root_url
    end
  end 
end
