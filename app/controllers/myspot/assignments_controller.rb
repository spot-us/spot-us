class Myspot::AssignmentsController < ApplicationController
  before_filter :login_required
  resources_controller_for :assignments, :only => :index
  
  private

  def find_resources
    current_user.assignments.paginate(:page=>params[:page])
  end
end
