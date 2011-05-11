class Myspot::PurchasesController < ApplicationController
  include ActiveMerchant::Billing::Integrations

  before_filter :login_required, :except => [:paypal_ipn]
  ssl_required :create, :new
  before_filter :unpaid_donations_required, :except => [:paypal_ipn, :paypal_return]
  before_filter :set_donation_amount_and_pitch
  skip_before_filter :verify_authenticity_token, :only => [:paypal_ipn, :paypal_return]

  def new
    if cookies[:spotus_lite]
  		render :layout=>'lite'
  	else
  		#render :partial => "/myspot/purchases/purchase_form"
  	end
  end

  def create
    @purchase                 = Purchase.new(params[:purchase])
    @purchase.user            = current_user
    
    donation_amount = params[:donation_amount]
    spotus_amount = params[:spotus_donation_amount]
    
    # create the donation and do not run any the limiting to existing donations rules
    d = Donation.create(:user_id => current_user.id, :pitch_id => params[:pitch_id], :amount => donation_amount, :donation_type => "payment")
    
    # add the session id
    session[:donation_id] = d.id
    
    # create the spotus donation
    spotus_donation = SpotusDonation.create(:user_id => current_user.id, :amount => spotus_amount)
    
    @purchase.donations       = [d]
    @purchase.spotus_donation = spotus_donation
    
    begin
      if @purchase.save
        set_social_notifier_cookie("donation")
        update_balance_cookie
        redirect_url = d && d.pitch ? pitch_url(d.pitch) : myspot_donations_path
        redirect_to cookies[:spotus_lite] ? "/lite/#{cookies[:spotus_lite]}" : redirect_url
      else
        unless cookies[:spotus_lite]
          render :action => 'new'
        else
          render :action => 'new', :layout=>'lite'
        end
      end
    rescue ActiveMerchant::ActiveMerchantError, Purchase::GatewayError => e
      flash[:error] = e.message
      unless cookies[:spotus_lite]
        render :action => 'new'
      else
        render :action => 'new', :layout=>'lite'
      end
    end
  end

  def paypal_return
    update_balance_cookie
    flash[:notice] = "Thanks! We are processing your donation and it will appear on the site when PayPal has processed it."
    redirect_to cookies[:spotus_lite] ? "/lite/#{cookies[:spotus_lite]}" : myspot_donations_path
  end

  def paypal_ipn
    notify = Paypal::Notification.new(request.raw_post)
    
    paypal_params = notify.params
    paypal_tmp = params[:item_number1]  
    arr = paypal_tmp.split("-")
    pitch_id = arr[1]
    user_id = arr[2]
    
    donation_amount = params[:mc_gross_1]
    spotus_donation_amount = params[:mc_gross_2]
    
    # create the donation and do not run any the limiting to existing donations rules
    d = Donation.create(:user_id => user_id, :pitch_id => pitch_id, :amount => donation_amount, :donation_type => "payment")
    unless d.errors.empty?
      logger.info('Donation errors:')
      d.errors.each do |key,e|
        logger.info("Error: " + e)
      end
    end
    
    # create the spotus donation
    spotus_donation = SpotusDonation.create(:user_id => user_id, :amount => spotus_donation_amount)
    
    unless spotus_donation.errors.empty?
      logger.info('SpotusDonation errors:')
      spotus_donation.errors.each do |key,e|
        logger.info("Error: " + e)
      end
    end
    
    user = User.find_by_id(user_id)

    purchase = Purchase.new
    purchase.spotus_donation = spotus_donation
    purchase.donations = [d]
    purchase.user = user
    purchase.paypal_transaction_id = notify.transaction_id

    if notify.acknowledge
      if notify.complete? and purchase.total_amount == BigDecimal.new(notify.amount.to_s)
        purchase.save
      else
        unless purchase.errors.empty?
          logger.info('Purchase errors:')
          purchase.errors.each do |key,e|
            logger.info("Error: " + e)
          end
        end
        logger.error("PayPal acknowledgement was unpaid or the amounts didn't match for the following transaction: #{notify.params['txn_id']}")
      end
    else
      logger.error("Failed to verify Paypal's notification, please investigate: #{notify.params['txn_id']}")
    end

    render :nothing => true
  end

  protected

  def unpaid_donations_required
    # redirect_to myspot_donations_path if current_user.donations.unpaid.empty? && (current_user.unpaid_spotus_donation.nil? || current_user.unpaid_spotus_donation.amount <= 0)
  end

  def set_donation_amount_and_pitch
    @donation_amount = 0
    @donation_amount = params[:total_amount].to_f if params[:total_amount] && @donation_amount==0
    @donation_amount = params[:amount_1].to_f if params[:amount_1] && @donation_amount==0
    @donation_amount = params[:donation_amount].to_f if params[:donation_amount] && @donation_amount==0
    @donation_amount = cookies[:donation_total_amount].to_f if cookies[:donation_total_amount] && @donation_amount==0
    
    @pitch = Pitch.find_by_id(params[:pitch_id].to_i) if params[:pitch_id]
    @pitch = Pitch.find_by_id(cookies[:donation_pitch_id].to_i) if cookies[:donation_pitch_id] && !@pitch
    
    cookies[:donation_pitch_id] = nil
    cookies[:donation_total_amount] = nil
  end

end
