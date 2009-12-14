class Admin::CitySuggestionsController < ApplicationController
    before_filter :admin_required
    layout "bare"
    resources_controller_for :city_suggestions, :only => [:index, :destroy]
    
    protected
    def find_resources
      @city_suggestions ||= CitySuggestion.paginate(:page => params[:page], :per_page => 50, :order => "created_at desc")
    end
end