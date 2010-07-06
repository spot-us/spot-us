ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'homes', :action => 'show'
  map.start_story 'start_story', :controller => 'homes', :action => "start_story"
  map.categories 'networks/:id/categories', :controller => 'networks', :action => 'categories'

  map.connect "/get_external_url/:width/:height", :controller=>"sections", :action=>"link", :width=>nil, :height=>nil
  map.connect "/sitemap.:type", :controller => "sitemap", :action => "index"
  map.connect "/sitemap_news.:type", :controller => "sitemap", :action => "index", :news=>true
  map.connect "/contributors.:format", :controller => "users", :action => "list", :filter=>'donated'
  map.connect "/contributors/:filter.:format", :controller => "users", :action => "list", :requirements => {:filter=>/#{FILTERS_CONTRIBUTORS_STRING}/}

  #better route support for the search page
  map.connect "stories.:format", :controller => "news_items", :action => "index", :filter=>'unfunded'
  map.connect "stories/:filter.:format", :controller => "news_items", :action => "index", :filter=>nil, :length=>"short", :requirements => {:filter=>/#{FILTERS_STORIES_STRING}/}
  map.connect "stories/:filter/:length.:format", :controller => "news_items", :action => "index", :filter=>nil, :requirements => {:filter=>/#{FILTERS_STORIES_STRING}/}
  map.connnect "news_items", :controller => "news_items", :action => "search", :sort_by=>'asc'
  
  map.connect '/auth/facebook', :controller => "sessions", :action => "facebook_login"
  map.connect '/auth/facebook/callback', :controller => "sessions", :action => "facebook_callback"

  map.connect '/auth/twitter', :controller => "myspot/twitter_credentials", :action => "twitter_login"
  map.connect '/auth/twitter/callback', :controller => "myspot/twitter_credentials", :action => "twitter_callback"

  map.connect '/notifications/social_notify', :controller => "notifications", :action => "social_notify"
  
  map.resources :news_items, :collection => {:search => :any, :sort_options => :get}
    
  map.resources :donations, :credit_pitches, :affiliations, :pledges, :profiles, :pages, :groups
  map.resources :stories, :member => {:accept => :put, :reject => :put, :fact_check => :put, :publish => :put}, :has_many => :comments
  map.resources :tips, :has_many => [:affiliations, :comments]
  map.resources :subscribers
  map.resources :blogs
  map.resources :channels
  map.resources :city_suggestions
  map.resources :sections
  
  map.resources :pitches, :member => {:begin_story => :get, :feature => :get, :unfeature => :get, :half_fund => :put, :fully_fund => :put, :show_support => :put, :apply_to_contribute => :get, :assign_fact_checker => :put, :blog_posts => :get} do |pitch|
    pitch.resources :posts, :except => [:index, :show]
    pitch.resources :comments, :except => [:index, :show]
    pitch.resources :assignments, :except => [:index, :show], :member => {:process_application => :get, :open_assignment => :get, :close_assignment => :get}
  end
  map.connect "pitches/:id/blog_posts", :controller => "pitches", :action => "index", :tab=>'posts'
  map.connect "pitches/:id/widget", :controller => "pitches", :action => "widget"
  map.connect "pitches/:id/:tab.:format", :controller => "pitches", :action => "show", :requirements => {:tab=>/posts|comments|assignments/}
  map.connect "pitches/:id/:tab/:item_id", :controller => "pitches", :action => "show", :item_id=>nil, :requirements => {:tab=>/posts|comments|assignments/}
  
  map.connect "test_spotus_lite/:id", :controller => "lite", :action => "test"
  map.connect "lite", :controller => "lite", :action => "index"
  map.connect "lite/helper", :controller => "lite", :action => "helper"
  map.connect "lite/:id/:sub", :controller => "lite", :action => "index", :sub=>nil
  
  #map.connect "/cca/submit_answers", :controller => "cca", :action => "submit_answers"
  #map.connect "/cca/apply_credits/:id", :controller => "cca", :action => "apply_credits"
  #map.connect "/cca/:id", :controller => "cca", :action => "show"
  map.resources :cca, :only=>[:show], :member=>{:submit_answers=>:put, :apply_credits=>:get, :results=>:get}
  map.connect "/cca/:id/:pitch_id", :controller => "cca", :action => "show"
  # facebook acct link
  #map.resources :users, :collection => {:link_user_accounts => :get}
  map.connect "users/link_user_accounts", :controller => "users", :action => "link_user_accounts"
  map.connect "search", :controller => "pages", :action => "search_results"
  map.connect "subscription/confirm/:id", :controller => "subscribers", :action => "confirm"
  map.connect "subscription/cancel/:id", :controller => "subscribers", :action => "cancel"
  map.connect "/assignment/:assignment_id/application/accept/:id", :controller => "assignments", :action => "accept_application"
  map.connect "/assignment/:assignment_id/application/reject/:id", :controller => "assignments", :action => "reject_application"
  map.connect "/update_assignments", :controller => "assignments", :action => "update_assignments"
  map.connect "/admin/channels/:id/add_pitch/:pitch_id", :controller => "admin/channels", :action => "add_pitch"
  map.connect "/admin/channels/:id/remove_pitch/:pitch_id", :controller => "admin/channels", :action => "remove_pitch"
  map.connect "/admin", :controller => "admin/city_suggestions", :action => "index"

  map.connect "/profiles/:id/:section", :controller => "profiles", :action => "profile", :requirements => {:section=>/assignments|pledges|donations|pitches|posts|tips|comments/}
  
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
                         :controller  => 'myspot/donation_amounts',
                         :member=>{:spotus_lite=>:get}

  map.namespace :admin do |admin|
    admin.resources :users, :member => {:log_in_as => :get, :promote_to_sponsor => :get, :approve => :put}
    admin.resources :credits
    admin.resources :pitches, :member => { :fact_checker_chooser => :get, :approve => :put, :unapprove => :put} #, :approve_blogger => :put, :unapprove_blogger => :put 
    admin.resources :tips
    admin.resources :comments
    admin.resources :subscribers
    admin.resources :city_suggestions
    admin.resources :site_options
    admin.resources :networks
    admin.resources :groups
    admin.resources :posts
    admin.resources :channels
    admin.resources :sections
    admin.resources :ccas, :member => { :credits => :get }
    admin.resources :cca_questions
    admin.resources :feedbacks
  end

  map.connect "/myspot/purchases/paypal_return", :controller => "myspot/purchases", :action => "paypal_return"
  map.connect "/myspot/purchases/paypal_ipn", :controller => "myspot/purchases", :action => "paypal_ipn"
  
  map.namespace :myspot do |myspot|
    myspot.resource :profile do |profile|
      profile.resources :jobs
      profile.resources :samples
    end

    myspot.resource :settings
    myspot.resource :twitter_credentials
    myspot.resources :donations
    myspot.resources :credit_pitches
    myspot.resources :pitches, :member => {:accept => :put}
    myspot.resources :posts
    myspot.resources :pledges
    myspot.resources :purchases
    myspot.resources :tips
    myspot.resources :comments
    myspot.resources :assignments
    myspot.resources :ccas
  end

  #notifications urls
  map.connect "notify/:code/:notification", :controller => 'notifications', :action => 'index', :notification=>nil

  map.connect '*path', :controller => 'homes', :action => 'show'
end

