class AssignmentsController < ApplicationController
  resources_controller_for :assignment
  before_filter :login_required, :except => [:show, :index]


  response_for :create do |format|
    # @assignment.assignment_created_notification
    format.html do
      if resource_saved?
        flash[:success] = 'Successfully created assignment'
        redirect_to pitch_assignment_path(@assignment.pitch, @assignment)
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
        redirect_to pitch_assignment_path(@assignment.pitch, @assignment)
      else
        flash[:error] = 'There was an error updating your assignment'
        render :action => 'edit'
      end
    end
  end
  
  def process_application
    assignment = Assignment.find(params[:id])
    redirect_to :back if !assignment || assignment.is_closed?
    respond_to do |format|
      format.html do
        if assignment.process_application(current_user)
          flash[:success] = 'You have Successfully applied as a contributor for this assignment. The creator if this pitch will be notified.'
          redirect_to pitch_assignment_path(assignment.pitch, assignment)
        else
          flash[:error] = 'There was an error applying for this assignment'
          redirect_to pitch_assignments_path(assignment.pitch)
        end
      end
    end
  end
  
  def accept_application
    assignment = Assignment.find(params[:assignment_id])
    redirect_to :back if !assignment || assignment.is_closed?
    application = AssignmentContributor.find(params[:id])
    redirect_to pitch_assignments_path(assignment.pitch) if assignment.user != current_user || !application 
    if application.accept
      flash[:success] = 'Application status is now set to "accepted"'
      redirect_to pitch_assignment_path(assignment.pitch, assignment)
    else
      flash[:error] = 'There was an error changing application status'
      redirect_to pitch_assignments_path(assignment.pitch)
    end
  end
  
  def reject_application
    assignment = Assignment.find(params[:assignment_id])
    redirect_to :back if !assignment || assignment.is_closed?
    application = AssignmentContributor.find(params[:id])
    redirect_to pitch_assignments_path(assignment.pitch) if assignment.user != current_user || !application
    if application.reject
      flash[:success] = 'Application status is now set to "rejected"'
      redirect_to pitch_assignment_path(assignment.pitch, assignment)
    else
      flash[:error] = 'There was an error changing application status'
      redirect_to pitch_assignments_path(assignment.pitch)
    end
  end
    
  def open_assignment
    @assignment = Assignment.find(params[:id])
    redirect_to :back if !@assignment
    redirect_to pitch_assignments_path(@assignment.pitch) if @assignment.user != current_user
    if @assignment.open
      flash[:success] = 'Assignment status is now set to "open".'
    else
      flash[:success] = 'Assignment status was unable to be changed.'
    end
    redirect_to pitch_assignment_path(@assignment.pitch, @assignment)
  end
  
  def close_assignment
    @assignment = Assignment.find(params[:id])
    redirect_to :back if !@assignment
    redirect_to pitch_assignments_path(@assignment.pitch) if @assignment.user != current_user
    if @assignment.close
      flash[:success] = 'Assignment status is now set to "closed".'
    else
      flash[:success] = 'Assignment status was unable to be changed.'
    end
    redirect_to pitch_assignment_path(@assignment.pitch, @assignment)
  end

  private

  def new_resource
    returning resource_service.new(params[resource_name]) do |resource|
      resource.user = current_user
    end
  end

  # def authorized?
  #   current_user && enclosing_resource.assignable_by?(current_user)
  # end
end
