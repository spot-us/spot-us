class Myspot::CcasController < ApplicationController
  before_filter :login_required
  resources_controller_for :ccas, :only => :index
  
  private

  def find_resources
    current_user.ccas.paginate(:page=>params[:page])
  end
  
end