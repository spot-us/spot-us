class Admin::UsersController < ApplicationController
  before_filter :admin_required
  layout "bare"

  def log_in_as
    self.current_user = User.find(params[:id])
    create_current_login_cookie
    update_balance_cookie
    redirect_to root_path
  end
  
  def promote_to_sponsor
    user = User.find(params[:id])
    user.type = 'Sponsor'
    user.save
    redirect_to profile_path(user)
  end

  def approve
    org = Organization.find(params[:id])
    org.approve!
    org.activate!
    redirect_to(admin_user_path(org))
  end
  
  def search
    conditions = ""
    @users = User.search params[:search_term], :order => :created_at, :sort_mode => :desc, :conditions => conditions, :page => params[:page], :per_page=>10, :retry_stale => true
  end

  # GET /users
  # GET /users.xml
  def index
    @users = User.paginate(:page=>params[:page])
    @fact_checkers = User.find_all_by_fact_check_interest(true)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
      format.csv do
        csv_string = User.generate_csv

        # send it to the browsah
        send_data csv_string, :type => 'text/csv; charset=iso-8859-1; header=present',
                              :disposition => "attachment; filename=users.csv"
      end
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    # we have to manually set this due to attr_accessible mass-assignment guard on the model
    @user.type = params[:user][:type]

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(admin_user_path(@user)) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(admin_user_path(@user)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(admin_users_url) }
      format.xml  { head :ok }
    end
  end
end
