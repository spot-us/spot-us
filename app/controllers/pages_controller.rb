class PagesController < ApplicationController
  PAGES = %w(
    about
    contact
    license
    press
    privacy
    quick_donate
    reporter_contract
    terms
  ).freeze

  def show
    if PAGES.include?(params[:id])
      render :action => params[:id]
    else
      raise ActiveRecord::RecordNotFound,
            "No such static page: #{params[:id].inspect}"
    end
  end
end
