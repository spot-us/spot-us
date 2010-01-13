class Myspot::CommentsController < ApplicationController
  before_filter :login_required
  resources_controller_for :comments, :only => :index

  def accept 
  end

  private

  def find_resources
    current_user.comments
  end
end
