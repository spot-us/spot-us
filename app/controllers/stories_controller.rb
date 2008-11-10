class StoriesController < ApplicationController
  before_filter :can_view?, :only => [:show]  
  resources_controller_for :stories
  
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
    redirect_back_or_default("/")
  end
  
  def fact_check
    story = find_resource
    story.verify!
    flash[:notice] = "Your story has been sent to the fact checker"
    redirect_back_or_default("/")
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
end