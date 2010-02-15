ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'homes', :action => 'show'
  map.start_story 'start_story', :controller => 'homes', :action => "start_story"
  map.categories 'networks/:id/categories', :controller => 'networks', :action => 'categories'

  map.connect "/sitemap.:type", :controller => "sitemap", :action => "index"
  map.connect "/sitemap_news.:type", :controller => "sitemap", :action => "index", :news=>true

  map.resources :news_items, :collection => {:search => :any, :sort_options => :get}  do |news_items|
    news_items.resources :newest
    news_items.resources :oldest
    news_items.resources :almost_funded
  end
    
  map.resources :donations, :credit_pitches, :affiliations, :pledges, :profiles, :pages, :groups
  map.resources :stories, :member => {:accept => :put, :reject => :put, :fact_check => :put, :publish => :put}, :has_many => :comments
  map.resources :tips, :has_many => [:affiliations, :comments]
  map.resources :subscribers
  map.resources :blogs
  map.resources :channels
  map.resources :city_suggestions
  map.resources :sections
  
  map.resources :pitches, :member => {:feature => :get, :unfeature => :get, :half_fund => :put, :fully_fund => :put, :show_support => :put, :apply_to_contribute => :get, :assign_fact_checker => :put, :blog_posts => :get} do |pitch|
    pitch.resources :posts, :except => [:index, :show]
    pitch.resources :comments, :except => [:index, :show]
    pitch.resources :assignments, :except => [:index, :show], :member => {:process_application => :get, :open_assignment => :get, :close_assignment => :get}
  end
  map.connect "pitches/:id/widget", :controller => "pitches", :action => "widget"
  map.connect "pitches/:id/:tab.:format", :controller => "pitches", :action => "show", :requirements => {:tab=>/posts|comments|assignments/}
  map.connect "pitches/:id/:tab/:item_id", :controller => "pitches", :action => "show", :item_id=>nil, :requirements => {:tab=>/posts|comments|assignments/}
  
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
  map.connect "/admin", :controller => "admin/city_suggestions", :action => "index"
  
  map.connect "/profiles/:id/assignments", :controller => "profiles", :action => "assignments"
  map.connect "/profiles/:id/pledges", :controller => "profiles", :action => "pledges"
  map.connect "/profiles/:id/donations", :controller => "profiles", :action => "donations"
  map.connect "/profiles/:id/pitches", :controller => "profiles", :action => "pitches"
  map.connect "/profiles/:id/posts", :controller => "profiles", :action => "posts"
  map.connect "/profiles/:id/tips", :controller => "profiles", :action => "tips"
  map.connect "/profiles/:id/comments", :controller => "profiles", :action => "comments"
  
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

