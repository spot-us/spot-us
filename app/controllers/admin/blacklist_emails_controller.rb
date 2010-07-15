class Admin::BlacklistEmailsController < ApplicationController
  
  before_filter :admin_required
  layout 'bare'
  resources_controller_for :blacklist_emails
  
  def index
    load_blacklisted_emails
    @blacklist_email = BlacklistEmail.new
  end
  
  def create
    @blacklist_email = BlacklistEmail.new(params[:blacklist_email])
    if @blacklist_email.save
      redirect_to admin_blacklist_emails_path
    else
      load_blacklisted_emails
      render :action => 'index'
    end
  end
  
  protected
  
  def load_blacklisted_emails
    @blacklist_emails = BlacklistEmail.paginate(:page => params[:page], :order => 'created_at desc')
  end
  
end
