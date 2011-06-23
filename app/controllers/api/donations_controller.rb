require 'oauth/controllers/provider_controller'

class Api::DonationsController < ApplicationController

  include OAuth::Controllers::ProviderController

  ssl_required :card
  before_filter :login_or_oauth_required

  def card

    arr = {}

    current_user = current_token.user
    
    purchase                 = Purchase.new(params[:purchase])
    purchase.user            = current_user

    donation_amount = params[:donation_amount]
    spotus_amount = params[:donation_amount] * SpotusDonation::SPOTUS_TITHE

    # create the donation and do not run any the limiting to existing donations rules
    d = Donation.create(:user_id => current_user.id, :pitch_id => params[:pitch_id], :amount => donation_amount, :donation_type => "payment")

    # create the spotus donation
    spotus_donation = SpotusDonation.create(:user_id => current_user.id, :amount => spotus_amount)

    purchase.donations       = [d]
    purchase.spotus_donation = spotus_donation

    arr = {}

    begin
      if purchase.save
        arr[:success] = "Congratulations! You have donated to the pitch"
        arr[:id] = d.id
        arr[:donation] = { :amount => donation_amount, :processing_fee => spotus_amount, :total_amount => donation_amount * (1+SpotusDonation::SPOTUS_TITHE)  }
      else
        arr[:errors] = purchase.errors.full_messages
      end
    rescue ActiveMerchant::ActiveMerchantError, Purchase::GatewayError => e
      arr[:errors] = [e.message]
    end
    
    render :json => arr
    return

  end

end
