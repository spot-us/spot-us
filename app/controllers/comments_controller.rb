class CommentsController < ApplicationController
  before_filter :login_required

  resources_controller_for :comments, :only => [:create, :index]

  response_for :create do |format|
    format.html do
      if resource_saved?
        flash[:notice] = "Successfully created comment"
        redirect_to :back
      else
        flash[:error] = "An error occurred while trying to post your comment."
        redirect_to enclosing_resource
      end
    end
  end

  response_for :index do |format|
    format.any do
      redirect_to(enclosing_resource)
    end
  end

  protected
  def new_resource
    returning resource_service.new(params[resource_name]) do |resource|
      resource.user = current_user
    end
  end

  def resource_service
    if enclosing_resource
      enclosing_resource.comments
    else
      Comment
    end
  end

end
