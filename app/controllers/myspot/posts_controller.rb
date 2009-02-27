class Myspot::PostsController < ApplicationController
  resources_controller_for :posts, :only => :index

end
