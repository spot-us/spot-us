class Myspot::DonationAmountsController < ApplicationController

  before_filter :login_required

  def edit
    @user      = current_user
    @donations = @user.donations.unpaid
  end

  def update
    @user = current_user
    @user.attributes = params[:user]
    if @user.save
      redirect_to new_myspot_purchase_path
    else
      @donations = current_user.donations.unpaid
      render :action => 'edit'
    end
  end

end
