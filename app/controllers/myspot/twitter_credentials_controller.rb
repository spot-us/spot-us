class Myspot::TwitterCredentialsController < ApplicationController
  resources_controller_for :twitter_credentials
  
  response_for :create do |format|
    format.html do
      if resource_saved?
        flash[:success] = "You have successfuly linked your twitter credentials to your account!"
        redirect_to myspot_twitter_credentials_path
      else
        render :action => 'new'
      end
    end
  end
  
  response_for :update do |format|
    format.html do
      if resource_saved?
        flash[:success] = "You have successfully updated your twitter credentials to your account!"
        redirect_to edit_myspot_twitter_credentials_path
      else
        render :action => 'edit'
      end
    end
  end
  
  private
  
  def find_resource
    current_user.twitter_credential ? current_user.twitter_credential : TwitterCredential.new(:user_id=>current_user.id)
  end
  
end
