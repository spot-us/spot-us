class Myspot::PledgesController < ApplicationController
  before_filter :login_required
  resources_controller_for :pledges, :only => :index

  private

  def find_resources
    current_user.pledges.paginate(:all, :page => params[:page])
  end
end
