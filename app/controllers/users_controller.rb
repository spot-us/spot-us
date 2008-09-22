class UsersController < ApplicationController
  include AuthenticatedSystem

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.type = params[:user][:type]
    if @user.save
      @user = User.find(@user.to_param)
      self.current_user = @user
      flash[:success] = 'Check your e-mail for your password, then login to change it.'
    else
      render :template => 'sessions/new'
    end
  end
end

