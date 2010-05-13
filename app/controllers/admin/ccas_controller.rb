class Admin::CcasController < ApplicationController
  before_filter :admin_required
  before_filter :load_users, :only => [:new, :edit, :update]
  layout 'bare'
  resources_controller_for :ccas

  def index
    @ccas = Cca.paginate(:page => params[:page])
  end
  
  def credits
    @cca = Cca.find_by_id(params[:id])
    @credits = @cca.credits.paginate(:page => params[:page], :conditions=>'credits.amount>0')
  end
  
  def show
    @cca = Cca.find_by_id(params[:id])
    @cca_question = CcaQuestion.new
  end
  
  response_for :create do |format|
    format.html do
      if resource_saved?
        flash[:success] = "You have successfuly created a new cca!"
        redirect_to admin_ccas_path
      else
        render :action => 'new'
      end
    end
  end
  
  response_for :update do |format|
    format.html do
      if resource_saved?
        flash[:success] = "You have successfully edited the cca!"
        redirect_to admin_ccas_path
      else
        render :action => 'edit'
      end
    end
  end

  protected 
  
  def load_users
    @users = User.sponsors_and_admins :all, :order => "last_name asc, first_name asc" # this could be huge list ... 
  end 
end