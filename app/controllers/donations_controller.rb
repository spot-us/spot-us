class DonationsController < ApplicationController
  
  before_filter :login_required, :except => :create  
  resources_controller_for :donations, :only => [:create, :destroy]

  response_for :create do |format|
    if resource_saved?
      update_balance_cookie
      render :update do |page|
        page.redirect_to edit_myspot_donations_amounts_path
      end
    else
      format.js { render :action => "new"}
    end
  end

  
  response_for :destroy do |format|
    update_balance_cookie
    format.html { redirect_to edit_myspot_donations_amounts_path }
  end
  
  protected

  def can_create?
    if current_user.nil?                             
      render :update do |page| 
        session[:return_to] = edit_myspot_donations_amounts_path                           
        page.redirect_to new_session_path(:news_item_id => params[:donation][:pitch_id],
                                          :donation_amount => params[:donation][:amount],
                                          :escape => false)
      end and return false
    end
    
    access_denied unless Donation.createable_by?(current_user)
  end
  
  def new_resource
    current_user.donations.new(params[:donation])
  end

  def find_resources
    current_user.donations.unpaid
  end
    
end