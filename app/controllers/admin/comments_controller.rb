class Admin::CommentsController < ApplicationController
    before_filter :admin_required
    layout "bare"
    resources_controller_for :comments, :only => [:index, :destroy]
    
    protected
    def find_resources
      @comments ||= Comment.paginate(:page => params[:page], :per_page => 10, :order => "created_at desc")
    end
end
