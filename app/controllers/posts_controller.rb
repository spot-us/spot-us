class PostsController < ApplicationController
  resources_controller_for :post
  before_filter :login_required

  private

  def authorized?
    current_user && (current_user.admin? || resource.user == current_user)
  end
end
