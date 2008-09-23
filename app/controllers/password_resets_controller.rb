class PasswordResetsController < ApplicationController

  def new
    @user = User.new
  end

  def create
     if @user = User.find_by_email(params[:email])
       @user.reset_password!
       flash[:success] = 'Your password has been reset. Please check your email.'
       redirect_to new_session_url
     else
       @user = User.new
       flash[:error] = 'We did not recognize that email address. Please check your spelling.'
       render :action => 'new'
     end
  end

end
