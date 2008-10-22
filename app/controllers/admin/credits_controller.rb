class Admin::CreditsController < ApplicationController
  def index
    @credits = Credit.find :all, :order => 'created_at desc'
  end
end