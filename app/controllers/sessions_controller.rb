require "digest/sha1"

class SessionsController < ApplicationController
  #ssl_required :create
	# require 'rubygems'
	# require 'sinatra'
	# require 'oauth2'
	# require 'json'
	#before_filter :load_oauth_client, :only => ["facebook_login"]

	def oauth_client
		OAuth2::Client.new(FACEBOOK_CONSUMER_KEY, FACEBOOK_CONSUMER_SECRET, :site => 'https://graph.facebook.com')
	end

	def facebook_login
		# get '/auth/facebook' do
		#debugger
		redirect_to oauth_client.web_server.authorize_url(
			:redirect_uri => redirect_uri,
			:display => "page"
			#, 
			#:scope => 'email,offline_access'
		)
	end
	
	def facebook_callback
	# get '/auth/facebook/callback' do
		access_token = oauth_client.web_server.get_access_token(params[:code], :redirect_uri => redirect_uri)
	  user = JSON.parse(access_token.get('/me'))
	  #debugger
		if current_user
			@user = current_user
			@user.link_identity!(user.id)
			# otherwise locate or create a new native account and associate 
		else
			@user = User.from_identity(user)
			self.current_user = @user
			flash[:notice] = "Welcome to Spot.Us."
			
		end
		# put these in a method
		# handle_remember_me
		#debugger
    create_current_login_cookie
    # update_balance_cookie
    # handle_first_donation_for_non_logged_in_user
    # handle_first_pledge_for_non_logged_in_user
	  redirect_to "/"
	end

	def redirect_uri
		uri = URI.parse(request.url)
		uri.path = '/auth/facebook/callback'
		uri.query = nil
		uri.to_s
	end

	def new
		@user = User.new
		store_news_item_for_non_logged_in_user
		store_comment_for_non_logged_in_user
		store_location(params[:return_to] || root_path)
		if request.xhr?
			render :partial => "header_form"
		end
	end

	def create
		self.current_user = User.authenticate(params[:email], Base64.decode64(params[:encoded_password]))
		if params[:link_facebook] == "true"
			self.current_user.link_fb_connect(facebook_session.user.id) unless self.current_user.fb_user_id == facebook_session.user.id
		end
		if logged_in?

			handle_remember_me
			create_current_login_cookie
			update_balance_cookie
			handle_first_donation_for_non_logged_in_user
			handle_first_pledge_for_non_logged_in_user

			if params[:return_to]
				redirect_to params[:return_to]
				return 
			elsif request.xhr?
				render :nothing => true
			else
				redirect_back_or_default('/')
			end
		else
			@user = User.new
			if params[:return_to]
				redirect_to params[:return_to]
				return 
			elsif request.xhr?
				set_ajax_flash(:error, 'Invalid email or password.')
				render :status => :unprocessable_entity, :nothing => true
			else
				render 'new'
			end
		end
	end

	def destroy
		self.current_user.forget_me if logged_in?
		delete_cookie :auth_token
		delete_cookie :balance_text
		delete_cookie :current_user_full_name
		reset_session
		flash[:notice] = "Later. Hope to see you again soon."
		redirect_back_or_default('/')
	end

	def show
		redirect_to(new_session_path)
	end

	protected

	def handle_remember_me
		if params[:remember_me] == "1"
			current_user.remember_me unless current_user.remember_token?
			set_cookie("auth_token", { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at })
		end
	end

	def store_news_item_for_non_logged_in_user
		if params[:news_item_id] && (params[:donation_amount] || params[:pledge_amount])
			session[:return_to] = edit_myspot_donations_amounts_path
			session[:news_item_id] ||= params[:news_item_id]
			session[:donation_amount] ||= params[:donation_amount]
			session[:pledge_amount] ||= params[:pledge_amount]
		end
	end

end

