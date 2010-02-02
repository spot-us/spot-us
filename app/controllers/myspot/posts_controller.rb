class Myspot::PostsController < ApplicationController
  resources_controller_for :posts, :only => :index
  def find_resources
    current_user.posts.paginate(:page=>params[:page])
  end
end
