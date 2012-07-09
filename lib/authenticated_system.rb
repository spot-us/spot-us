module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      !!current_user
    end
    
    def banned?
      current_user && current_user.is_banned?
    end

    # Accesses the current user from the session. 
    # Future calls avoid the database because nil is not equal to false.
    def current_user
      @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_user == false
      # supporting facebooker/facebook connect
      #@current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie || login_from_fb) unless @current_user == false 
    end
    
    
    # facebook login
    def login_from_fb
      if fb_session
        self.current_user = User.find_by_fb_user(fb_session["id"].to_i)
      end
    end
    
    # Store the given user id in the session.
    def current_user=(new_user)
      session[:user_id] = new_user ? new_user.id : nil
      @current_user = new_user || false
    end

    # Check if the user is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_user.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    def admin_required
      access_denied unless logged_in? && current_user.is_a?(Admin) 
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied(opts = {})
      respond_to do |format|
        format.any do
          flash[:error] = opts[:flash] || 'You must be logged in to access this page.'
          store_location
          store_purchase
          redirect_to opts[:redirect] || new_session_path
        end
      end
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location(url = nil)
      session[:return_to] = url || request.request_uri
    end
    
    def store_purchase
      session[:return_to] = "https://#{APP_CONFIG[:default_host]}/purchase/#{params[:pitch_id]}"
      cookies[:donation_total_amount] = params[:total_amount]
      cookies[:donation_pitch_id] = params[:pitch_id]
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :store_location
    end

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_user = User.authenticate(username, password)
      end
    end

    # Called from #current_user.  Finally, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        self.current_user = user
        cookies[:current_user_full_name] = user.full_name
        cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
        update_balance_cookie
        user
      end
    end
end
