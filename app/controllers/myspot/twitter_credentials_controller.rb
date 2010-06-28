class Myspot::TwitterCredentialsController < ApplicationController
  resources_controller_for :twitter_credentials
  # before_filter :login_required, :only => [:twitter_login, :twitter_callback]
  
  # require "twitter"
	include OauthConnect

	def twitter_login
		session[:request_token] = twitter_access_token
		if session[:request_token] && session[:request_token].authorize_url
			redirect_to session[:request_token].authorize_url  # "http://twitter.com/oauth/authorize?oauth_token=#{}"
		else
			flash[:notice] = "Error connecting to Twitter"
			redirect_to :back
		end
	end

	def twitter_callback
		client = twitter_oauth_client
		access_token = client.authorize(session[:request_token].token,session[:request_token].secret,:oauth_verifier => params[:oauth_verifier])
		if client.authorized?
			if current_user.twitter_credential
				current_user.twitter_credential.access_token = (access_token.token + "," + access_token.secret)
				current_user.twitter_credential.save!
				current_user.twitter_credential
			else
				TwitterCredential.create(:user_id => current_user.id, :access_token => (access_token.token + "," + access_token.secret))
			end
		else
			flash[:notice] = "Error authorizing Twitter"
		end
		redirect_to edit_myspot_twitter_credentials_path	
	end
	
  response_for :destroy do |format|
    format.html do
		flash[:notice] = "You have disconnected your Twitter account."
      	redirect_to edit_myspot_twitter_credentials_path
    end
  end
  
  # response_for :create do |format|
  #   format.html do
  #     if resource_saved?
  #       flash[:success] = "You have successfuly linked your twitter credentials to your account!"
  #       redirect_to myspot_twitter_credentials_path
  #     else
  #       render :action => 'new'
  #     end
  #   end
  # end
  # 
  # response_for :update do |format|
  #   format.html do
  #     if resource_saved?
  #       flash[:success] = "You have successfully updated your twitter credentials to your account!"
  #       redirect_to edit_myspot_twitter_credentials_path
  #     else
  #       render :action => 'edit'
  #     end
  #   end
  # end
  
  private
  
  def find_resource
     @settings = current_user
     current_user.twitter_credential ? current_user.twitter_credential : TwitterCredential.new(:user_id=>current_user.id)
  end
  
end
