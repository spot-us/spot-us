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
    credit_pitch_amounts = params[:credit_pitch_amounts]
    if donation_amounts
      @donations = Donation.update(donation_amounts.keys, donation_amounts.values)
    end
    
    if credit_pitch_amounts && current_user.has_enough_credits?(credit_pitch_amounts)
          @credit_pitches = CreditPitch.update(credit_pitch_amounts.keys, credit_pitch_amounts.values)
    end
    
    if donation_amounts.nil? || @donations.all?{|d| d.valid? }
      spotus_donation.update_attribute(:amount, params[:spotus_donation_amount])
      update_balance_cookie
      redirect_to new_myspot_purchase_path
    else
      update_balance_cookie
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

