class PledgesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :login_required, :except => :create 
  resources_controller_for :pledges, :only => [:create, :update, :destroy]

  response_for :create do |format|
    if resource_saved?
      format.js 
    else
      format.js { render :action => "new"}
    end
  end
  
  response_for :update do |format|
    if resource_saved?
      format.js 
    else
      format.js { render :action => "edit"}
    end
  end
  
  
  protected

  def can_create?
    if current_user.nil?                            
      render :update do |page|
        session[:return_to] = search_news_items_path(:news_item_type=>'tips', :sort_by=>'desc')
        page.redirect_to new_session_path(:news_item_id => params[:pledge][:tip_id],
                                          :pledge_amount => params[:pledge][:amount],
                                          :escape => false)
      end and return false
    end
    
    access_denied unless Pledge.createable_by?(current_user)
  end

  def resources_url
    myspot_pledges_url
  end

  def can_edit?
    access_denied unless find_resource.editable_by?(current_user)
  end

  def new_resource
    current_user.pledges.new(params[:pledge])
  end
end
