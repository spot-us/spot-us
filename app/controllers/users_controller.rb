class UsersController < ApplicationController
  include AuthenticatedSystem

  def create
    cookies.delete :auth_token

    opt_in_defaults = {
      :notify_tips => true,
      :notify_pitches => true,
      :notify_stories => true,
      :notify_spotus_news => true
    }
    
    user_attributes = params[:user].merge(opt_in_defaults)

    # @user = (params[:user][:type] || "User").constantize.new(user_attributes)
    @user = User.new(user_attributes)
    @user.type = params[:user][:type]
    if @user.save
      # This is a crappy way of dealing with the fact that when using STI the way we were 
      # on line 16 it doesn't set the created at field wierdness
      if params[:user][:type] == "Organization"
        @user.status = "needs_approval"
        @user.save
      end
      @user = User.find(@user.to_param)
      self.current_user = @user
      flash[:success] = 'Check your e-mail for your password, then login to change it.'
    else
      render :template => 'sessions/new'
    end
  end
end
