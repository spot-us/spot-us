class PagesController < ApplicationController
  before_filter :select_tab   
    
  PAGES = %w(
    about
    contact
    dmc_agreement
    license
    media_partners
    press
    privacy
    quick_donate
    reporter_agreement
    reporter_contract
    terms
    who
  ).freeze

  def show
    if PAGES.include?(params[:id])
      render :action => params[:id]
    else
      raise ActiveRecord::RecordNotFound,
            "No such static page: #{params[:id].inspect}"
    end
  end

  def index
    redirect_to root_path
  end
  
  protected
  
  def select_tab
      @selected_tab = "about" if params[:id] == "about"
  end
end
