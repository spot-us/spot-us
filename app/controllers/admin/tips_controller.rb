class Admin::TipsController < ApplicationController
  before_filter :admin_required
  layout "bare"
  
  resources_controller_for :tips, :only => [:index, :destroy]
  
end