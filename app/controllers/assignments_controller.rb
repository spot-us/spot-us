class AssignmentsController < ApplicationController
  resources_controller_for :assignment
  before_filter :login_required, :except => [:show, :index]


  response_for :create do |format|
    # @assignment.assignment_created_notification
    format.html do
      if resource_saved?
        flash[:success] = 'Successfully created assignment'
        redirect_to assignment_path(@assignment)
      else
        flash[:error] = 'There was an error saving your assignment'
        render :action => 'new'
      end
    end
  end

  response_for :update do |format|
    format.html do
      if resource_saved?
        flash[:success] = 'Successfully updated assignment'
        redirect_to assignment_path(@assignment)
      else
        flash[:error] = 'There was an error updating your assignment'
        render :action => 'edit'
      end
    end
  end

  # response_for :destroy do |format|
  #   format.html do
  #     redirect_to myspot_posts_path
  #   end
  # end

  private

  def new_resource
    returning resource_service.new(params[resource_name]) do |resource|
      resource.user = current_user
    end
  end

  def authorized?
    current_user && enclosing_resource.assignable_by?(current_user)
  end
end
