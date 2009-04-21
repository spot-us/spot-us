class Myspot::DonationsController < ApplicationController
  before_filter :login_required, :except => :create
  resources_controller_for :donations, :only => [:index, :create, :destroy]

  def create
    unless params[:email].blank?
      self.current_user = User.authenticate(params[:email], params[:password])
    end
    self.resource = new_resource
    if resource.save
      update_balance_cookie
      redirect_to edit_myspot_donations_amounts_path
    else
      render "new"
    end
  end

  response_for :destroy do |format|
    update_balance_cookie
    format.html { redirect_to edit_myspot_donations_amounts_path }
  end

  protected

  def new_resource
    Donation.new(params[:donation]) do |d|
      d.user = current_user
    end
  end

  def find_resources
    current_user.donations.paid.paginate(:page => params[:page])
  end
end
