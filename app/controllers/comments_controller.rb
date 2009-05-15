class CommentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :login_required

  bounce_bots :send_bots, :comment, :blog_url

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

  def send_bots
    redirect_to root_path
  end

  def can_create?
    if current_user.nil?
      store_comment_for_non_logged_in_user
      render :partial => "sessions/header_form" and return false
    end

    access_denied unless current_user
  end

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
