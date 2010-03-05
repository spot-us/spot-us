class TipsController < ApplicationController
  resources_controller_for :tip, :except => :destroy

  before_filter :block_if_donated_to, :only => :edit
  before_filter :login_required, :only => [:new, :create, :update]  
  bounce_bots(:send_bots, :tip, :blog_url)
  # before_filter :select_tab, :only => [:new]
  before_filter :set_meta_tags, :only => [:show]

  def block_if_donated_to
    t = find_resource(params[:id])
    if t.pledged_to? && !t.editable_by?(current_user)
      access_denied(:flash => "You cannot edit a tip that has pledges.  For minor changes, contact info@spot.us",
                    :redirect => tip_url(t))
    end
  end

  def index
    redirect_to "/stories/suggested", :status=>301
    return
  end

  private

  def send_bots
    self.resource = new_resource
    render :action => :new
  end

  def can_edit?
    access_denied unless find_resource.editable_by?(current_user)
  end

  def can_create?
    true
    #access_denied unless Tip.createable_by?(current_user)
  end

  def new_resource
    params[:tip] ||= {}
    params[:tip][:headline] = params[:headline] if params[:headline]
    current_user.tips.new(params[:tip])
  end
  
  protected

    # def select_tab
    #    @selected_tab = "suggest_story"
    # end
    
    def set_meta_tags
       tip = find_resource
       html_meta_tags(tip.short_description,tip.keywords) if tip
    end

end
