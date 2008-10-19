class SessionsController < ApplicationController
  include AuthenticatedSystem

  def new
    @user = User.new
  end

  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
    else
      @user = User.new
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "Later. Hope to see you again soon."
    redirect_back_or_default('/')
  end
end

