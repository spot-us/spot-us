ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'homes', :action => 'show'

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

  map.namespace :myspot do |myspot|
    myspot.resource :profile
  end
end

