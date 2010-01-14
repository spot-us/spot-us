class PitchesController < ApplicationController
  before_filter :store_location, :only => :show
  before_filter :login_required, :only => [:new, :create, :update, :apply_to_contribute]
  before_filter :organization_required, :only => [:half_fund, :fully_fund, :show_support]
  before_filter :set_meta_tags, :only => [:show]
  before_filter :select_tab, :only => [:new]
  after_filter :send_edited_notification, :only => [:update]

  layout "widget", :only=>:widget
  resources_controller_for :pitch

  bounce_bots(:send_bots, :pitch, :blog_url)

  def index
    redirect_to(news_items_path)
  end
  
  def apply_to_contribute
    pitch = find_resource
    pitch.apply_to_contribute(current_user)
    flash[:success] = "You're signed up!  Thanks for applying to join the reporting team."
    redirect_to pitch_path(pitch)
  end

  def feature
    pitch = find_resource
    pitch.feature!
    redirect_to pitch_path(pitch)
  end

  def feature
    pitch = find_resource
  end

  def unfeature
    pitch = find_resource
    pitch.unfeature!
    redirect_to pitch_path(pitch)
  end

  def widget
    @pitch = find_resource
  end

  def show_support
    pitch = find_resource
    pitch.show_support!(current_user)
    flash[:success] = "Thanks for your support!"
    redirect_to pitch_path(pitch)
  end

  def fully_fund
    pitch = find_resource
    if donation = pitch.fully_fund!(current_user)
      flash[:success] = "Your donation was successfully created"
      redirect_to edit_myspot_donations_amounts_path
    else
      flash[:error] = "An error occurred while trying to fund this pitch"
      redirect_to pitch_path(pitch)
    end
  end

  def half_fund
    pitch = find_resource
    if donation = pitch.half_fund!(current_user)
      flash[:success] = "Your donation was successfully created"
      redirect_to edit_myspot_donations_amounts_path
    else
      flash[:error] = "An error occurred while trying to fund this pitch"
      redirect_to pitch_path(pitch)
    end
  end

  def blog_posts
    respond_to do |format|
      format.rss do
        @posts = find_resource.posts.first(10)
        render :layout => false
      end
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

    pitch = find_resource

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
      pitch = find_resource
      html_meta_tags(pitch.short_description,pitch.keywords) if pitch
  end
  
  def select_tab
     @selected_tab = "start_story"
  end
  
  def send_edited_notification
    pitch = find_resource
    pitch.send_edited_notification unless current_user.admin?
  end

end
