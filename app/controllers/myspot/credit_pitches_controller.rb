class Myspot::CreditPitchesController < ApplicationController
  before_filter :login_required, :except => :create
  resources_controller_for :credit_pitches, :only => [:index, :create, :destroy]

  response_for :create do |format|
    if resource_saved?
      update_balance_cookie
      format.html { redirect_to edit_myspot_donations_amounts_path }
    else
      format.html {
        flash[:error] = 'There was a problem with your credit. Please try again'
        redirect_to :back
      }
    end
  end

  response_for :destroy do |format|
    update_balance_cookie
    format.html { redirect_to edit_myspot_donations_amounts_path }
  end

  protected

  def can_create?
    if current_user.nil?
      session[:return_to] = edit_myspot_donations_amounts_path
      session[:news_item_id] = params[:pitch_id]
      session[:donation_amount] = params[:amount]
      render :partial => "sessions/header_form" and return false
    end

    access_denied unless CreditPitch.createable_by?(current_user)
  end

  def new_resource
    current_user.credit_pitches.new(params[:credit_pitch])
  end
end
