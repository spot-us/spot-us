ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'homes', :action => 'show'
  map.start_story 'start_story', :controller => 'homes', :action => "start_story"
  map.categories 'networks/:id/categories', :controller => 'networks', :action => 'categories'

  map.resources :news_items, :collection => {:search => :any, :sort_options => :get}
  map.resources :donations, :affiliations, :pledges, :profiles, :pages
  map.resources :stories, :member => {:accept => :put, :reject => :put, :fact_check => :put, :publish => :put}, :has_many => :comments
  map.resources :tips, :has_many => [:affiliations, :comments]
  map.resources :pitches, :member => {:feature => :put, :unfeature => :put}, :has_many => :comments do |pitch|
    pitch.resources :posts
  end

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
    admin.resources :pitches, :member => { :fact_checker_chooser => :get }
    admin.resources :tips
    admin.resources :site_options
    admin.resources :networks
  end

  map.namespace :myspot do |myspot|
    myspot.resource :profile do |profile|
      profile.resources :jobs
      profile.resources :samples
    end

    myspot.resource :settings
    myspot.resources :donations
    myspot.resources :pitches, :member => {:accept => :put}
    myspot.resources :posts
    myspot.resources :pledges
    myspot.resources :purchases
    myspot.resources :tips
  end

  map.connect '*path', :controller => 'homes', :action => 'show'
end

