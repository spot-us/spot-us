ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'homes', :action => 'show'

  map.resources :news_items
  map.resources :donations
  map.resources :tips
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

  map.namespace :myspot do |myspot|
    myspot.resource :profile
    myspot.resource :settings
    myspot.resources :purchases
    myspot.resources :donations
    myspot.resources :pledges
    myspot.resources :tips
    myspot.resources :pitches
  end

end

