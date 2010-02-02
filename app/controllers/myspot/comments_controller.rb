class Myspot::CommentsController < ApplicationController
  before_filter :login_required
  resources_controller_for :comments, :only => :index
  
  private

  def find_resources
    current_user.comments.paginate(:page=>params[:page])
  end
end
