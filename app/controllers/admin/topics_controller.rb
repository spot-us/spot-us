class Admin::TopicsController < ApplicationController
  
  resources_controller_for :topics
  before_filter :admin_required
  layout 'bare'

  
end
