require 'oauth/controllers/provider_controller'

class Api::UsersController < ApplicationController

  include OAuth::Controllers::ProviderController

  before_filter :verify_oauth_consumer_signature

  def create
    
    user = User.new(params[:user])

    params[:password] = User.random_password
    params[:password_confirmation] = User.random_password

    arr = {}

    if user.save
      
      unless user.organization?
        user.activate!
        arr[:success] = 'You have successfully created an account at Spot.Us. You will receive an email with your details.'
      else
        arr[:success] = "Your account will be reviewed prior to approval. Spot.us will get back to you as soon as possible."
      end
      
      token = @current_client_application.create_from_request_token(user,params[:oauth_token],session[params[:oauth_token]],params[:oauth_verifier])
      
      arr[:token] = { :token => token.token }
      
      render :json => arr.to_json
      return
    else
      render :json => { :errors => @user.errors.full_messages }.to_json
      return
    end
  end

end
