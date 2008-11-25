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

    @user = (params[:user][:type] || "User").constantize.new(user_attributes)

    if @user.save
      flash[:success] = 'Check your e-mail for your password, then login to change it.'
    else
      render :template => 'sessions/new'
    end
  end
end
