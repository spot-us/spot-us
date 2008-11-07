class StoriesController < ApplicationController
  before_filter :can_view?, :only => [:show]  
  resources_controller_for :stories
  
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