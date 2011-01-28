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
    redirect_to "/stories/unfunded", :status=>301
    return
  end
  
  def blog_posts
    pitch = Pitch.find_by_id(params[:id])
    pitch = Pitch.find_by_id(params[:pitch_id]) unless pitch
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
    pitch = Pitch.find_by_id(params[:id])
    pitch = Pitch.find_by_id(params[:pitch_id]) unless pitch
    pitch.current_funding = pitch.total_amount_donated.to_f
    pitch.save
    redirect_to :back
  end
  
  def show
    @pitch = Pitch.find_by_id(params[:id])
    @pitch = Pitch.find_by_id(params[:pitch_id]) unless @pitch
    @filter = params[:filter] || ""
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
    pitch = Pitch.find_by_id(params[:id])
    pitch = Pitch.find_by_id(params[:pitch_id]) unless pitch
    pitch.apply_to_contribute(current_user)
    flash[:success] = "You're signed up!  Thanks for applying to join the reporting team."
    redirect_to pitch_path(pitch)
  end

  def feature
    pitch = Pitch.find_by_id(params[:id])
    pitch = Pitch.find_by_id(params[:pitch_id]) unless pitch
    if pitch.featureable_by?(current_user)
      pitch.feature!
    end
    redirect_to pitch_path(pitch)
  end

  def unfeature
    pitch = Pitch.find_by_id(params[:id])
    pitch = Pitch.find_by_id(params[:pitch_id]) unless pitch
    if pitch.featureable_by?(current_user)
      pitch.unfeature!
    end
    redirect_to pitch_path(pitch)
  end
  
  def begin_story
    pitch = Pitch.find_by_id(params[:id])
    pitch = Pitch.find_by_id(params[:pitch_id]) unless pitch
    redirect_to pitch_url(pitch) if !pitch || (current_user && current_user.id != pitch.user.id)
    pitch.create_associated_story 
    redirect_to edit_story_path(pitch.story)
  end

  def widget
    @pitch = Pitch.find_by_id(params[:id])
    @pitch = Pitch.find_by_id(params[:pitch_id]) unless @pitch
    render :layout => "widget"
  end

  def show_support
    pitch = Pitch.find_by_id(params[:id])
    pitch = Pitch.find_by_id(params[:pitch_id]) unless pitch
    pitch.show_support!(current_user)
    flash[:success] = "Thanks for your support!"
    redirect_to pitch_path(pitch)
  end

  def fully_fund
    pitch = Pitch.find_by_id(params[:id])
    pitch = Pitch.find_by_id(params[:pitch_id]) unless pitch
    if donation = pitch.fully_fund!(current_user)
      flash[:success] = "Your donation was successfully created"
      redirect_to edit_myspot_donations_amounts_path
    else
      flash[:error] = "An error occurred while trying to fund this pitch"
      redirect_to pitch_path(pitch)
    end
  end

  def half_fund
    pitch = Pitch.find_by_id(params[:id])
    pitch = Pitch.find_by_id(params[:pitch_id]) unless pitch
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

    pitch = Pitch.find_by_id(params[:id])
    pitch = Pitch.find_by_id(params[:pitch_id]) unless pitch

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
    pitch = Pitch.find_by_id(params[:id])
    pitch = Pitch.find_by_id(params[:pitch_id]) unless pitch
    html_meta_tags(pitch.short_description,pitch.keywords) if pitch
  end
  
  # def select_tab
  #    @selected_tab = "start_story"
  # end
  
  def send_edited_notification
    pitch = find_resource
    pitch.send_edited_notification unless current_user.admin?
  end

end
