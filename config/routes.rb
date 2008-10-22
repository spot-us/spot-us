ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'homes', :action => 'show'

  map.resources :news_items
  map.resources :donations
  map.resources :affiliations
  map.resources :tips, :has_many => :affiliations
  map.resources :pledges
  map.resources :pitches
  map.resources :profiles
  map.resources :pages

  # TODO: remove when done
  map.resources :ui
  
  map.resource :user

  map.resource :session
  map.destroy_session 'logout', :controller => 'sessions', :action => 'destroy'

  map.resource :password_reset

  map.resource :amounts, :name_prefix => 'myspot_donations_',
                         :path_prefix => 'myspot/donations',
                         :controller  => 'myspot/donation_amounts'
                         
  map.namespace :admin do |admin|
    admin.resources :users, :member => {:log_in_as => :get, :approve => :put}
    admin.resources :credits 
    admin.resources :pitches 
    admin.resources :tips 
  end

  map.namespace :myspot do |myspot|
    myspot.resource :profile do |profile|
      profile.resources :jobs
      profile.resources :samples
    end

    myspot.resource :settings
    myspot.resources :donations
    myspot.resources :pitches, :member => {:accept => :put}
    myspot.resources :pledges
    myspot.resources :purchases
    myspot.resources :tips
  end
end

