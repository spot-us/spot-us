class ProfilesController < ApplicationController
  resources_controller_for :profiles, :class => User, :only => [:show]
end
