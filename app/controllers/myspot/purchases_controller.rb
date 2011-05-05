class Myspot::PurchasesController < ApplicationController
  include ActiveMerchant::Billing::Integrations

  before_filter :login_required, :except => [:paypal_ipn]
  ssl_required :create, :new
  before_filter :unpaid_donations_required, :except => [:paypal_ipn, :paypal_return]
  skip_before_filter :verify_authenticity_token, :only => [:paypal_ipn, :paypal_return]

  def new
    #@donations = current_user.donations.unpaid
    #@purchase = Purchase.new(:user       => current_user,
    #                         :donations  => @donations,
    #                         :spotus_donation => current_user.current_spotus_donation,
    #                         :first_name => current_user.first_name,
    #                         :last_name  => current_user.last_name)
    @donation_amount = 0
    @donation_amount = params[:total_amount].to_f if params[:total_amount] && @donation_amount==0
    @donation_amount = params[:amount_1].to_f if params[:amount_1] && @donation_amount==0
    @donation_amount = params[:donation_amount].to_f if params[:donation_amount] && @donation_amount==0
    @donation_amount = cookies[:donation_total_amount].to_f if cookies[:donation_total_amount] && @donation_amount==0
    
    @pitch = Pitch.find_by_id(params[:pitch_id].to_i) if params[:pitch_id]
    @pitch = Pitch.find_by_id(cookies[:donation_pitch_id].to_i) if cookies[:donation_pitch_id] && !@pitch
    
    cookies[:donation_pitch_id] = nil
    cookies[:donation_total_amount] = nil
    
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
    spotus_amount = params[:spotus_amount]
    
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

    #@spotus_donation = SpotusDonation.find_from_paypal(notify.params)
    #@donations = Donation.find_all_from_paypal(notify.params)
    
    paypal_params = notify.params
    paypal_tmp = paypal_params.select{|k,v| k =~ /item_number_1/}
    arr = paypal_tmp.split("-")
    pitch_id = arr[1]
    user_id = arr[2]
    
    donation_amount = paypal_params.select{|k,v| k =~ /amount_1/}
    spotus_donation_amount = paypal_params.select{|k,v| k =~ /amount_2/}
    
    # create the donation and do not run any the limiting to existing donations rules
    d = Donation.create(:user_id => user_id, :pitch_id => pitch_id, :amount => donation_amount, :donation_type => "payment")

    # add the session id
    session[:donation_id] = d.id
    
    # create the spotus donation
    spotus_donation = SpotusDonation.create(:user_id => user_id, :amount => spotus_amount)
    
    @user = User.find_by_id(user_id)

    #unless Purchase.valid_donations_for_user?(@user, [@donations, @spotus_donation].flatten.compact)
    #  logger.error("Invalid users for PayPal transaction 28C98632UU123291R")
    #  render :nothing => true and return
    #end

    purchase = Purchase.new
    purchase.spotus_donation = @spotus_donation
    purchase.donations = [d]
    purchase.user = @user
    purchase.paypal_transaction_id = notify.transaction_id

    if notify.acknowledge
      if notify.complete? and purchase.total_amount == BigDecimal.new(notify.amount.to_s)
        purchase.save
        set_social_notifier_cookie("donation")
		
      else
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

end
