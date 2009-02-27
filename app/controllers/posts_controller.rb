class PostsController < ApplicationController
  resources_controller_for :post
  before_filter :login_required

  response_for :create do |format|
    format.html do
      redirect_to myspot_posts_path
    end
  end

  response_for :destroy do |format|
    format.html do
      redirect_to myspot_posts_path
    end
  end

  private

  def authorized?
    current_user && (current_user.admin? || enclosing_resource.user == current_user)
  end
end
