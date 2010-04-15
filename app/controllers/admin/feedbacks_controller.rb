class Admin::FeedbacksController < ApplicationController
    before_filter :admin_required
    layout "bare"
    resources_controller_for :feedbacks, :only => [:index, :destroy]
    
    protected
    def find_resources
      @feedbacks ||= Feedback.paginate(:page => params[:page], :per_page => 50, :order => "created_at desc")
    end
end