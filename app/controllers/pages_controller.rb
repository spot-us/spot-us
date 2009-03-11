class PagesController < ApplicationController
  PAGES = %w(
    about
    contact
    license
    news_org_partners
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
end
