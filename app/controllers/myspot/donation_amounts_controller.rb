class Myspot::DonationAmountsController < ApplicationController

  before_filter :login_required, :except => [:show]
  helper_method :unpaid_donations, :spotus_donation

  def show
    redirect_to :action => 'edit'
  end

  def edit
  end

  def update
    donation_amounts = params[:donation_amounts]
    @donations = Donation.update(donation_amounts.keys, donation_amounts.values)
    if @donations.all?{|d| d.valid? }
      spotus_donation.update_attribute(:amount, params[:spotus_donation_amount])
      redirect_to new_myspot_purchase_path
    else
      @close_flash_link = edit_myspot_donations_amounts_path
      render :action => 'edit'
    end
  end

  protected

  def unpaid_donations
    @unpaid_donations ||= current_user.donations.unpaid
  end

  def spotus_donation
    @spotus_donation ||= current_user.current_spotus_donation
  end

end

