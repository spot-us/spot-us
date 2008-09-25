class Myspot::TipsController < ApplicationController
  before_filter :login_required
  resources_controller_for :tips, :only => :index
end
