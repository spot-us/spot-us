ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'homes', :action => 'show'

  map.resources :news_items
  map.resources :donations
  map.resources :tips
  map.resources :pledges
  map.resources :pitches
  map.resources :profiles

  # TODO: remove when done
  map.resources :ui
  
  map.resource :user
  map.signup  '/signup', :controller => 'users',    :action => 'new'

  map.resource :session
  map.login   '/login',  :controller => 'sessions', :action => 'new'
  map.logout  '/logout', :controller => 'sessions', :action => 'destroy'

  map.resource :password_reset

  map.resource :amounts, :name_prefix => 'myspot_donations_',
                         :path_prefix => 'myspot/donations',
                         :controller  => 'myspot/donation_amounts'

  map.namespace :myspot do |myspot|
    myspot.resource :profile
    myspot.resource :settings
    myspot.resources :purchases
    myspot.resources :donations
  end

end

