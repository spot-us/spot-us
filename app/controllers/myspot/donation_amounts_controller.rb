class Myspot::DonationAmountsController < ApplicationController

  before_filter :login_required, :except => [:show]
  helper_method :unpaid_donations, :unpaid_credits, :spotus_donation, :only=>:edit
  ssl_required :update, :edit

  def show
    if params[:spotus_lite]
      redirect_to :action => 'spotus_lite'
    else
      redirect_to :action => 'edit'
    end
  end

  def edit
  end

  def spotus_lite
    render :layout=>"lite"
  end

  def update
    
    SpotusDonation.delete_all(['purchase_id is null and credit_id is null and user_id=?', current_user.id])
    
    donation_amounts = params[:donation_amounts]
    credit_pitch_amounts = params[:credit_pitch_amounts]
    available_credits = current_user.total_credits
    credits = current_user.total_available_credits 
    
    #merge the amounts arrays
    amounts = {}
    amounts.merge!(donation_amounts) if donation_amounts
    amounts.merge!(credit_pitch_amounts) if credit_pitch_amounts
    
    @donations = []
    @credit_pitches = []
    
    amounts.each do |key, amount|
      available_credits = current_user.total_credits            # get the fresh number of available credits for each donation
      credits = current_user.total_available_credits            # get a fresh copy of credits for each donation
      donation_amount = amount["amount"]                        # get the donation amount
      if available_credits>0
        if donation_amount.to_f>available_credits
          if credits && !credits.empty?
            @credit_pitches, donation = apply_credits_per_donation_amount(credits, key, donation_amount.to_f, @donations, "Applied to Pitches (#{key})")
          else
            donation = Donation.update(key, amount)             # should never happen but you never know. :-)
          end 
        else
          if credits && !credits.empty?
            @credit_pitches, donation = apply_credits_per_donation_amount(credits, key, donation_amount.to_f, @credit_pitches, "Applied to Pitches (#{key})")
          else
            donation = Donation.update(key, amount)             # should never happen but you never know. :-)
          end
        end
      else
        donation = Donation.update(key, amount)
      end
      @donations << donation if donation
    end
    
    if params[:submit] == "update"
      redirect_to :back
    else
      params[:spotus_donation_amount] = params[:spotus_donation_amount_hidden] if params[:spotus_donation_amount_hidden]
      spotus_donation = SpotusDonation.create({ :amount => params[:spotus_donation_amount], :user_id => current_user.id  }) if !spotus_donation && params[:spotus_donation_amount] && params[:spotus_donation_amount].to_f>0
      if spotus_donation && !spotus_donation.amount.blank? && spotus_donation.amount.to_f>0     # todo: make sure we can pay the spotus donation in credits
        u = User.find_by_id(current_user.id)            # reload the user...
        available_credits = u.total_credits             # get the fresh number of available credits for each donation
        credits = u.total_available_credits             # get a fresh copy of credits for each donation
        spotus_donation.update_attribute(:amount, params[:spotus_donation_amount])
        spotus_donation_valid = true
        if available_credits>0
          if spotus_donation.amount.to_f > available_credits
            if credits && !credits.empty?
              spotus_donation = apply_credits_for_spotus_donation(credits, spotus_donation.id, spotus_donation.amount.to_f, "Donated to SpotUs")
            else
              spotus_donation = SpotusDonation.update(spotus_donation.id, { :amount => spotus_donation.amount.to_f })             # should never happen but you never know. :-)
            end
          else
            if credits && !credits.empty?
              spotus_donation = apply_credits_for_spotus_donation(credits, spotus_donation.id, spotus_donation.amount.to_f, "Donated to SpotUs")
            else
              spotus_donation = SpotusDonation.update(spotus_donation.id, { :amount => spotus_donation.amount.to_f })             # should never happen but you never know. :-)
            end
          end
        end
      else
        spotus_donation.destroy if spotus_donation
        spotus_donation_valid = false
      end
      update_balance_cookie
      if (@donations && !@donations.empty? && @donations.all?{|d| d.valid? }) || (spotus_donation && spotus_donation.unpaid? && spotus_donation_valid)
        session[:donation_id] = @donations.first.id if @donations.any?
		    redirect_to new_myspot_purchase_path
      else
        if !@credit_pitches || @credit_pitches.empty?
          redirect_to cookies[:spotus_lite] ? "/lite/#{cookies[:spotus_lite]}" : myspot_donations_path
        else
          set_social_notifier_cookie("donation")
          session[:donation_id] = @credit_pitches.first.id
          redirect_to cookies[:spotus_lite] ? "/lite/#{cookies[:spotus_lite]}" : pitch_url(@credit_pitches.first.pitch)
        end
      end
    end
  end
  
  protected
  
  # apply credits per donation and keep track of the credit id...
  def apply_credits_per_donation_amount(credits, key, donation_amount, donations, description = "")  
    d_pitch_id = nil
    paid_amount = 0
    credits.each do |credit|
      
      # if the credit is larger than the donation amount, slice off the remainer...
      if credit.amount > donation_amount
        sliced_off_credit = Credit.create(:user_id => credit.user_id, :description => "#{credit.description} (Sliced off from #{credit.id} which had the amount #{credit.amount})",
                        :amount => (credit.amount-donation_amount), :cca_id => credit.cca_id)
        credit.update_attributes(:amount => donation_amount)
      end  
      
      # pay the donation using the credit while the paid amount is larger than the donation amount...
      if paid_amount < donation_amount
        unless d_pitch_id
          d = Donation.update(key, { 'amount' => credit.amount, 'credit_id' => credit.id })
          d_pitch_id = d.pitch_id                                                                 # get the pitch id for the next cycle
        else
          d = Donation.create(:user_id => current_user.id, :pitch_id => d_pitch_id, :credit_id => credit.id, :amount => credit.amount)
        end
        d.pay!
        
        credit.update_attributes(:description => description)

        paid_amount += credit.amount
        donations << d
      end
      
    end    
    
    # left over of the donation to be covered by a purchase...
    donation = nil
    donation = Donation.create( :user_id => user_id = current_user.id, :pitch_id => d_pitch_id, :amount => (donation_amount-paid_amount)) if donation_amount > paid_amount

    return donations, donation
  end
  
  # separate logic for spotus donations for now (should be consolidated later on...)
  def apply_credits_for_spotus_donation(credits, key, spotus_donation_amount, description = "")  
    first_iteration = true
    paid_amount = 0
    credits.each do |credit|
       
      # if the credit is larger than the spotus donation amount, slice off the remainer...
      if credit.amount > spotus_donation_amount
        sliced_off_credit = Credit.create(:user_id => credit.user_id, :description => "#{credit.description} (Sliced off from #{credit.id} which had the amount #{credit.amount})",
                        :amount => (credit.amount-spotus_donation_amount), :cca_id => credit.cca_id)
        credit.update_attributes(:amount => spotus_donation_amount)
      end
      
      # pay the spotus donation using the credit while the paid amount is larger than the spotus donation amount...
      if paid_amount < spotus_donation_amount
        if first_iteration
          spotus_donation = SpotusDonation.update(key, { 'amount' => credit.amount, 'credit_id' => credit.id, :user_id => current_user.id })
          first_iteration = false
        else
          spotus_donation = SpotusDonation.create(:user_id => current_user.id, :credit_id => credit.id, :amount => credit.amount)
        end
        
        credit.update_attributes(:description => description)
      end
      
      paid_amount += credit.amount
    end    
    
    # left over of the spotus donation to be covered by a purchase...
    spotus_donation = nil
    spotus_donation = SpotusDonation.create(:user_id => current_user.id, :amount => (spotus_donation_amount-paid_amount)) if spotus_donation_amount > paid_amount
    
    return spotus_donation
  end

  def unpaid_donations
    @unpaid_donations ||= current_user.donations.unpaid
  end
  
  def unpaid_credits
    @unpaid_credits ||= current_user.credit_pitches.unpaid
  end

  def spotus_donation
    @spotus_donation ||= current_user.current_spotus_donation
  end

end

                     