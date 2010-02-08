class Admin::TipsController < ApplicationController
  before_filter :admin_required
  layout "bare"
  
  resources_controller_for :tips, :only => [:index, :destroy]
  
  def index
    @tips = Tip.paginate(:page => params[:page], :per_page => 40, :order => "created_at desc", :include => [:network, :pledges, :supporters, :category])
  end
end