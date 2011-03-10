class Admin::CreditsController < ApplicationController
  before_filter :admin_required
  layout "bare"
  
  def index
    load_credits
    @credit = Credit.new
  end
  
  def new
    load_users
  end
  
  def create
    @credit = Credit.new(params[:credit])
    if @credit.save
      redirect_to admin_credits_path
    else
      load_users
      render :action => 'new'
    end
  end
  
  def unused
    @credits = Credit.find(:all,
      :select => "credits.*, SUM(credits.amount) as total_amount", 
      :joins => "LEFT JOIN donations ON donations.credit_id = credits.id LEFT JOIN spotus_donations ON spotus_donations.credit_id = credits.id", 
      :conditions => "donations.id is null and spotus_donations.id is null", 
      :group => "credits.user_id having total_amount>0")
  end
  
  def transfer
    user = User.find_by_id(params[:user_id])
    credits = Credit.find(:all,
        :select => "credits.*", 
        :joins => "LEFT JOIN donations ON donations.credit_id = credits.id LEFT JOIN spotus_donations ON spotus_donations.credit_id = credits.id", 
        :conditions => "donations.id is null and spotus_donations.id is null and credits.user_id=#{params[:user_id]}")
        
    credits.each do |credit|
      spotus_donation = SpotusDonation.create({ :amount => credit.amount, :user_id => user.id, :credit_id => credit.id  })
    end
    
    redirect_to :back
  end
  
  private
  
  def load_users
    @users = User.find :all, :order => "last_name asc, first_name asc", :conditions=>'last_name is not null and first_name is not null' # this could be huge list ... 
  end
    
  def load_credits
    @credits = Credit.paginate(:page => params[:page], :per_page => 50, :order => "updated_at desc, created_at desc")
  end

end