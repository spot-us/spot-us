require "digest/sha1"

class SessionsController < ApplicationController

  include OauthConnect


	def facebook_login
		# '/auth/facebook' do
		#debugger
		redirect_to oauth_client.web_server.authorize_url(
			:redirect_uri => redirect_uri(request.url),
			:display => "page", # popup
			:scope => "publish_stream"
		)
	end
	
	def facebook_callback
	# get '/auth/facebook/callback' do
		access_token = fb_access_token(params[:code],request.url)
	  user = JSON.parse(access_token.get('/me'))
	  user ? session[:fb_session] = params[:code] : session[:fb_session] = nil
		if current_user
			@user = current_user
			@user.link_identity!(user["id"].to_i)
			# otherwise locate or create a new native account and associate 
		else
			@user = User.from_identity(user)
			self.current_user = @user
			flash[:notice] = "Welcome to Spot.Us."
		end
		
    create_current_login_cookie
    update_balance_cookie
    handle_first_donation_for_non_logged_in_user
		handle_first_pledge_for_non_logged_in_user
	  redirect_to "/"
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
	  if params[:link_facebook] == "true"
      # self.current_user.link_fb_connect(facebook_session.user.id) unless self.current_user.fb_user_id == facebook_session.user.id
      new_fb_user = current_user
    end
		self.current_user = User.authenticate(params[:email], Base64.decode64(params[:encoded_password]))

		if logged_in?
      current_user.connect_fb(new_fb_user) if new_fb_user
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

