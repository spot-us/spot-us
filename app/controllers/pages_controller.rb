class PagesController < ApplicationController
  PAGES = %w(about terms press).freeze

  def show
    if PAGES.include?(params[:id])
      render :action => params[:id]
    else
      raise ActiveRecord::RecordNotFound,
            "No such static page: #{params[:id].inspect}"
    end
  end
end
