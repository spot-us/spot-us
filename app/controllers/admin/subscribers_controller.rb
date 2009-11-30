class Admin::SubscribersController < ApplicationController
    before_filter :admin_required
    layout "bare"
    resources_controller_for :comments, :only => [:index]
    
    protected
    def find_resources
      @subscribers ||= Subscriber.paginate(:page => params[:page], :per_page => 50, :order => "created_at desc")
    end
end
