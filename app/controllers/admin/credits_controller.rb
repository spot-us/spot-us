class Admin::CreditsController < ApplicationController
  before_filter :admin_required
  layout "bare"
  
  def index
    @credits = Credit.find :all, :order => 'created_at desc'
  end
end