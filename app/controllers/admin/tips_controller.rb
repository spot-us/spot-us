class Admin::TipsController < ApplicationController
  before_filter :admin_required
  layout nil
  
  resources_controller_for :tips, :only => :index
  
end