class Myspot::PurchasesController < ApplicationController

  before_filter :login_required
  before_filter :unpaid_donations_required

  def new
    @donations = current_user.donations.unpaid
    @purchase = Purchase.new(:user       => current_user,
                             :donations  => @donations,
                             :first_name => current_user.first_name,
                             :last_name  => current_user.last_name)
  end

  def create
    @purchase           = Purchase.new(params[:purchase])
    @purchase.user      = current_user
    @donations          = current_user.donations.unpaid
    @purchase.donations = @donations

    begin
      if @purchase.save
        redirect_to myspot_donations_path
      else
        render :action => 'new'
      end
    rescue ActiveMerchant::ActiveMerchantError, Purchase::GatewayError => e
      flash[:error] = e.message
      render :action => 'new'
    end
  end

  protected

  def unpaid_donations_required
    redirect_to myspot_donations_path if current_user.donations.unpaid.empty?
  end

end
