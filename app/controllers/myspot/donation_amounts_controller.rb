class Myspot::DonationAmountsController < ApplicationController

  before_filter :login_required

  def edit
    # current_user (remove @user)
    # current_user.donations.unpaid.each do |unpaid_donation|
    #  new_amount = params['donation'][unpaid_donation.id]['amount'] 
    #  unpaid_donation.update_attribute :amount, new_amount
    # end
    #   
    @user      = current_user
    @donations = @user.donations.unpaid
    @spotus_donation = @user.current_spotus_donation
  end

  def update
    @user = current_user
    @user.donation_amounts = params[:user][:donation_amounts]

    if @user.save
      @spotus_donation = @user.current_spotus_donation
      @spotus_donation.amount = params[:user][:spotus_donation_amount]
      @spotus_donation.save if @spotus_donation.valid?
      redirect_to new_myspot_purchase_path
    else
      @donations = current_user.donations.unpaid
      @spotus_donation = @user.current_spotus_donation
      render :action => 'edit'
    end
  end

end

