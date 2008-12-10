class CommentsController < ApplicationController
  before_filter :login_required

  resources_controller_for :comments, :only => [:create]

  response_for :create do |format|
    format.html do
      if resource_saved?
        flash[:notice] = "Successfully created comment"
        redirect_to :back
      else
        render :action => :new
      end
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
