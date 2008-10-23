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
      redirect_to admin_credits_path
    else
      load_users_and_credits
      render :action => 'index'
    end
  end
  
  private
  
    def load_users_and_credits
      @users = User.find :all
      @credits = Credit.find :all, :order => 'created_at desc'
    end
end