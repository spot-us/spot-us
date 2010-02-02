class Myspot::TipsController < ApplicationController
  before_filter :login_required
  resources_controller_for :tips, :only => :index

  private

  def find_resources
    current_user.tips.paginate(:page=>params[:page])
  end
end
