class PledgesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :login_required, :except => :create
  resources_controller_for :pledges, :only => [:create, :update, :destroy]

  response_for :create do |format|
    if resource_saved?
      format.html { redirect_to search_news_items_path(:news_item_type=>'tips', :sort_by=>'desc') }
    else
      format.html {
        flash[:error] = resource.errors.full_messages
        redirect_to :back
      }
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
      session[:return_to] = search_news_items_path(:news_item_type=>'tips', :sort_by=>'desc')
      session[:news_item_id] = params[:tip_id]
      session[:pledge_amount] = params[:amount]
      render :partial => "sessions/header_form" and return false
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
