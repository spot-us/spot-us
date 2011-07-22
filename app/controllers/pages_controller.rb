class PagesController < ApplicationController
  #before_filter :select_tab   

  PAGES = %w(
    about
    contact
    dmc_agreement
    examples
    license
    press
    privacy
    quick_donate
    reporter_agreement
    reporter_contract
    sponsors
    support
    terms
    who
    notfound
  ).freeze

  def show
    @page = Page.find_by_slug(params[:id])
    if @page
      # render normal page
    elsif PAGES.include?(params[:id])
      @hide_gs = true if params[:id] == "support"
      if params[:id]!='reporter_agreement'
        render :action => params[:id]
      else
        render :action => params[:id], :layout => 'bare'
      end
    else
      raise ActiveRecord::RecordNotFound,
      "No such static page: #{params[:id].inspect}"
    end
  end
  
  def sponsors
    params[:id] = "Sponsors"
    @errors = nil
    valid_captcha = verify_recaptcha
    if params[:sponsor] && valid_captcha && params[:sponsor][:name] && params[:sponsor][:organization] && 
      params[:sponsor][:email] && params[:sponsor][:amount] && params[:sponsor][:number]
      Mailer.deliver_sponsor_signup_email(params[:sponsor])
      flash[:success] = "Thank you for your interest to become a sponsor! We will be in contact shortly."
      params[:sponsor] = nil
    elsif params[:sponsor]
      @errors  = "You have to provide all fields"
      @errors += ", and you have to provide the right captcha." 
    end
  end

  def notfound
  end

  def index
    redirect_to root_path
  end

  # protected
  # 
  # def select_tab
  #     @selected_tab = "about" if params[:id] == "about"
  # end
end
