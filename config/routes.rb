ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'homes', :action => 'show'
  map.start_story 'start_story', :controller => 'homes', :action => "start_story"
  map.categories 'networks/:id/categories', :controller => 'networks', :action => 'categories'

  map.resources :news_items, :collection => {:search => :any, :sort_options => :get}
  map.resources :donations, :credit_pitches, :affiliations, :pledges, :profiles, :pages, :groups
  map.resources :stories, :member => {:accept => :put, :reject => :put, :fact_check => :put, :publish => :put}, :has_many => :comments
  map.resources :tips, :has_many => [:affiliations, :comments]
  map.resources :subscribers
  map.resources :blogs
  map.resources :channels
  map.resources :city_suggestions
  
  map.resources :pitches, :member => {:feature => :put, :unfeature => :put, :half_fund => :put, :fully_fund => :put, :show_support => :put, :apply_to_contribute => :get, :assign_fact_checker => :put, :blog_posts => :get}, :has_many => :comments do |pitch|
    pitch.resources :posts
    pitch.resources :assignments, :member => {:process_application => :get, :open_assignment => :get, :close_assignment => :get}
  end
  map.connect "pitches/:id/widget", :controller => "pitches", :action => "widget"
  
  # facebook acct link
  #map.resources :users, :collection => {:link_user_accounts => :get}
  map.connect "users/link_user_accounts", :controller => "users", :action => "link_user_accounts"
  map.connect "search", :controller => "pages", :action => "search_results"
  map.connect "subscription/confirm/:id", :controller => "subscribers", :action => "confirm"
  map.connect "subscription/cancel/:id", :controller => "subscribers", :action => "cancel"
  map.connect "/assignment/:assignment_id/application/accept/:id", :controller => "assignments", :action => "accept_application"
  map.connect "/assignment/:assignment_id/application/reject/:id", :controller => "assignments", :action => "reject_application"
  map.connect "/admin/channels/:id/add_pitch/:pitch_id", :controller => "admin/channels", :action => "add_pitch"
  map.connect "/admin/channels/:id/remove_pitch/:pitch_id", :controller => "admin/channels", :action => "remove_pitch"
  # TODO: remove when done
  map.resources :ui

  map.resource :user, :only => [:new, :create, :activate],
    :collection => {
      :activation_email => :get,
      :resend_activation => :post,
      :password => :get,
      :reset_password => :put
    }
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'

  map.resource :session
  map.destroy_session 'logout', :controller => 'sessions', :action => 'destroy'

  map.resource :amounts, :name_prefix => 'myspot_donations_',
                         :path_prefix => 'myspot/donations',
                         :controller  => 'myspot/donation_amounts'

  map.namespace :admin do |admin|
    admin.resources :users, :member => {:log_in_as => :get, :approve => :put}
    admin.resources :credits
    admin.resources :pitches, :member => { :fact_checker_chooser => :get, :approve => :put, :unapprove => :put, :approve_blogger => :put, :unapprove_blogger => :put }
    admin.resources :tips
    admin.resources :comments
    admin.resources :subscribers
    admin.resources :city_suggestions
    admin.resources :site_options
    admin.resources :networks
    admin.resources :groups
    admin.resources :channels
  end

  map.namespace :myspot do |myspot|
    myspot.resource :profile do |profile|
      profile.resources :jobs
      profile.resources :samples
    end

    myspot.resource :settings
    myspot.resources :donations
    myspot.resources :credit_pitches
    myspot.resources :pitches, :member => {:accept => :put}
    myspot.resources :posts
    myspot.resources :pledges
    myspot.resources :purchases, :collection => {:paypal_return => :get, :paypal_ipn => :post}
    myspot.resources :tips
    myspot.resources :comments
    myspot.resources :assignments
  end

  map.connect '*path', :controller => 'homes', :action => 'show'
end

