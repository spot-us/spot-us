class UsersController < ApplicationController
  include AuthenticatedSystem

  def new
    @user = User.new
  end

  def create
    cookies.delete :auth_token
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = 'Click the link in the email we just sent you to finish creating your account!'
    end
    render :action => 'new'
  end

  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if current_user
      current_user.activate!
      login_cookies
      flash[:success] = "You have successfully activated your account - welcome to Spot.Us!"
      redirect_back_or_default('/')
    else
      flash[:error] = "Sorry, we were unable to find that activation code. Perhaps you have already activated your account?"
      redirect_to new_session_url
    end
  end
end


