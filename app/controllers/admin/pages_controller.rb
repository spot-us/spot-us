class Admin::PagesController < ApplicationController
  
  resources_controller_for :pages
  before_filter :admin_required
  layout 'bare'
  
  def create
    @page = Page.new(params[:page])
    if @page.save
      redirect_to "/pages/#{@page.slug?}"
      return
    end
    render :action => "new"
    return
  end
  
  def edit
    @page = Page.find_by_slug(params[:id])
    @page = Page.find_by_id(params[:id]) unless @page
  end
  
  def update
    @page = Page.find_by_id(params[:id])
    if @page.update_attributes(params[:page])
      redirect_to "/pages/#{@page.slug?}"
      return
    end
    params[:id] = @page.slug?
    render :action => "edit"
    return
  end
  
end
