class StoriesController < ApplicationController
  before_filter :can_view?, :only => [:show]
  before_filter :can_edit?, :only => :edit
  # before_filter :select_tab
  before_filter :set_meta_tags, :only => [:show]
  resources_controller_for :stories

  def index
    redirect_to "/stories/published", :status => :moved_permanently 
    return
  end
  
  def show
    @story = find_resource
    @pitch = @story.pitch
    respond_to do |format|
      format.html do
        redirect_to "#{pitch_path(@pitch)}/story", :status => :moved_permanently 
        return
      end
      format.xml do
      end
    end
  end

  def accept
    story = find_resource
    story.accept!
    flash[:notice] = "Your story has been submitted to spot.us personnel to be published"
    redirect_back_or_default("/")
  end

  def reject
    story = find_resource
    story.reject!
    flash[:notice] = "Your story has been sent back to the reporter for edits"
    redirect_to story_path(story)
  end

  def fact_check
    debugger
    story = find_resource
    story.verify!
    flash[:notice] = "Your story has been sent to the peer reviewer"
    redirect_to story_path(story)
  end

  def publish
    story = find_resource
    story.publish!
    flash[:notice] = "Your story has been published"
    redirect_back_or_default("/") 
  end

  protected
  
    def can_view?
      story = find_resource
      unless story.viewable_by?(current_user)
        access_denied( \
          :flash => "This story is not viewable at this time.",
          :redirect => pitch_url(story.pitch))
      end
    end

    def can_edit?
      story = find_resource
      if current_user.nil?
        access_denied( \
          :flash => "You cannot edit a story unless you are logged in.",
          :redirect => new_session_path)
      end
      unless story.editable_by?(current_user)
        access_denied( \
          :flash => "You cannot edit this story, contact info@spot.us",
          :redirect => story_url(story))
      end
    end

    def find_resources
      @stories = Story.by_network(current_network).published.paginate(:page => params[:page], :per_page => 10, :order=>"created_at desc")
    end
    
    # def select_tab
    #     @selected_tab = "stories"
    # end
    
    def set_meta_tags
      story = find_resource
      html_meta_tags(story.short_description,story.keywords) if story
    end
end
