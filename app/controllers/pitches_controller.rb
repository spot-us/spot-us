class PitchesController < ApplicationController
  before_filter :store_location, :only => :show
  before_filter :login_required, :only => [:new, :create, :update, :apply_to_contribute, :feature, :unfeature, :begin_story]
  before_filter :organization_required, :only => [:half_fund, :fully_fund, :show_support]
  before_filter :set_meta_tags, :only => [:show]
  # before_filter :select_tab, :only => [:new]
  after_filter :send_edited_notification, :only => [:update]
  before_filter :admin_required, :only => :reset_funding

  resources_controller_for :pitch

  bounce_bots(:send_bots, :pitch, :blog_url)

  def index
    redirect_to "/stories/unfunded", :status => :moved_permanently 
    return
  end
  
  def blog_posts
    pitch = get_pitch
    respond_to do |format|
      format.html do
        redirect_to "#{pitch_url(pitch)}/posts"
      end
      format.rss do
        redirect_to "#{pitch_url(pitch)}/posts.rss"
      end
    end
    return
  end
  
  def reset_funding
    pitch = get_pitch
    pitch.current_funding = pitch.total_amount_donated.to_f
    pitch.save
    redirect_to :back
  end
  
  def show
    @pitch = get_pitch
  
    if @pitch.blank?
      display_404 
      return
    end
    
    @tab = params[:tab] || ""
    
    if @tab=='posts'
      redirect_to "#{pitch_path(@pitch)}/updates", :status => :moved_permanently 
      return
    end
    
    @story = @pitch.story if @tab=='story'
    respond_to do |format|
      format.html do
        #if !@tab.blank? && params[:item_id]
        #  @item = @pitch.send(@tab).find_by_id(params[:item_id])
        #  redirect_to pitch_assignments_path(@pitch) if  @item.class.to_s == "Assignment" && @item.is_closed? && @item.user != current_user
        #end
      end
      format.xml do
        #if !@tab.blank? && params[:item_id]
        #  @item = @pitch.send(@tab).find_by_id(params[:item_id])
        #  redirect_to pitch_assignments_path(@pitch) if @item.class.to_s == "Assignment" && @item.is_closed? && @item.user != current_user
        #end
      end
      #unless @tab.blank?
      #  format.rss do
      #    render :layout => false
      #  end
      #end
    end
  end
  
  def apply_to_contribute
    pitch = get_pitch
    pitch.apply_to_contribute(current_user)
    flash[:success] = "You're signed up!  Thanks for applying to join the reporting team."
    redirect_to pitch_path(pitch)
  end

  def feature
    pitch = get_pitch
    if pitch.featureable_by?(current_user)
      pitch.feature!
    end
    redirect_to pitch_path(pitch)
  end

  def apply_credits
    pitch = get_pitch
    credits = current_user.total_available_credits
    credits.each do |credit|
      amount = credit.amount * (1-SpotusDonation::SPOTUS_TITHE)
      
      # slice off the spotus donation
      spotus_donation_credit = Credit.create(:user_id => credit.user_id, :description => "#{credit.description} (Sliced off from #{credit.id} which had the amount #{credit.amount})",
                      :amount => (credit.amount-amount), :cca_id => credit.cca_id)
      
      # update the credit
      credit.update_attributes(:amount => amount)
      
      # create the donation and do not run any the limiting to existing donations rules
      d = Donation.create(:user_id => current_user.id, :pitch_id => pitch.id, :credit_id => credit.id, :amount => amount, :donation_type => "credit", :applying_credits => true)
      d.pay!
      
      # add the session id
      session[:donation_id] = d.id
      
      # create the spotus donation
      spotus_donation = SpotusDonation.create(:user_id => current_user.id, :credit_id => spotus_donation_credit.id, :amount => spotus_donation_credit.amount)
    end
    set_social_notifier_cookie("donation")
    redirect_to pitch_path(pitch)
  end

  def unfeature
    pitch = get_pitch
    if pitch.featureable_by?(current_user)
      pitch.unfeature!
    end
    redirect_to pitch_path(pitch)
  end
  
  def begin_story
    pitch = get_pitch
    redirect_to pitch_url(pitch) if !pitch || (current_user && current_user.id != pitch.user.id)
    pitch.create_associated_story 
    redirect_to edit_story_path(pitch.story)
  end

  def widget
    @pitch = get_pitch
    @is_widget = true
    render :layout => "widget"
  end
  
  def get_widget
    @pitch = get_pitch
    @is_widget = true
    render :layout => "widget"
  end

  def show_support
    pitch = get_pitch
    pitch.show_support!(current_user)
    flash[:success] = "Thanks for your support!"
    redirect_to pitch_path(pitch)
  end

  def fully_fund
    pitch = get_pitch
    if donation = pitch.fully_fund!(current_user)
      flash[:success] = "Your donation was successfully created"
      redirect_to edit_myspot_donations_amounts_path
    else
      flash[:error] = "An error occurred while trying to fund this pitch"
      redirect_to pitch_path(pitch)
    end
  end

  def half_fund
    pitch = get_pitch
    if donation = pitch.half_fund!(current_user)
      flash[:success] = "Your donation was successfully created"
      redirect_to edit_myspot_donations_amounts_path
    else
      flash[:error] = "An error occurred while trying to fund this pitch"
      redirect_to pitch_path(pitch)
    end
  end

  protected
    
  def send_bots
    self.resource = new_resource
    render :action => :new
  end

  def can_create?
    access_denied unless Pitch.createable_by?(current_user)
  end

  def can_edit?

    pitch = get_pitch

    if not pitch.editable_by?(current_user)
      #if pitch.user == current_user
        #if pitch.donated_to?
        #  access_denied( \
        #    :flash => "You cannot edit a pitch that has donations.  For minor changes, contact info@spot.us",
        #    :redirect => pitch_url(pitch))
        #else
        #  access_denied( \
        #    :flash => "You cannot edit this pitch.  For minor changes, contact info@spot.us",
        #    :redirect => pitch_url(pitch))
        #end
      unless pitch.user == current_user
        access_denied( \
          :flash => "You cannot edit this pitch, since you didn't create it.",
          :redirect => pitch_url(pitch))
      end
    end
  end

  def new_resource
    params[:pitch] ||= {}
    params[:pitch][:headline] = params[:headline] if params[:headline]
    current_user.pitches.new(params[:pitch])
  end

  def organization_required
    access_denied unless current_user && current_user.organization?
  end
  
  def set_meta_tags
    pitch = get_pitch
    html_meta_tags(pitch.short_description,pitch.keywords) if pitch
  end
  
  # def select_tab
  #    @selected_tab = "start_story"
  # end
  
  def send_edited_notification
    pitch = find_resource
    pitch.send_edited_notification unless current_user.admin?
  end
  
  def get_pitch
    pitch = Pitch.find_by_id(params[:pitch_id])
    pitch = Pitch.find_by_id(params[:id]) unless pitch
    pitch
  end

end
