ActionController::Routing::Routes.draw do |map|
  map.resources :pitches

  # TODO: remove when done
  map.resources :ui
  
  map.resource :user
  map.signup  '/signup', :controller => 'users',    :action => 'new'

  map.resource :session
  map.login   '/login',  :controller => 'sessions', :action => 'new'
  map.logout  '/logout', :controller => 'sessions', :action => 'destroy'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

