class Admin::CreditsController < ApplicationController
  before_filter :admin_required
  layout "bare"
  
  def index
    load_users_and_credits
    @credit = Credit.new
  end
  
  def create
    @credit = Credit.new(params[:credit])
    if @credit.save
      update_balance_cookie
      redirect_to admin_credits_path
    else
      load_users_and_credits
      render :action => 'index'
    end
  end
  
  private
  
    def load_users_and_credits
      @users = User.find :all, :order => "last_name asc, first_name asc" # this could be huge list ... 
      @credits = Credit.paginate(:page => params[:page], :per_page => 50, :order => "updated_at desc, created_at desc")
    end
end