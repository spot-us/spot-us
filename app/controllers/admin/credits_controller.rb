class Admin::CreditsController < ApplicationController
  before_filter :admin_required
  layout "bare"
  
  def index
    @users = User.find :all
    @credits = Credit.find :all, :order => 'created_at desc'
  end
end