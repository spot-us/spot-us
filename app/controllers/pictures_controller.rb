class PicturesController < ApplicationController
  
  #resources_controller_for :picture
  
  def show
    @picture = Picture.find_by_id(params[:id])
    @cca = @picture.cca
  end
  
  def tag
    @picture = Picture.find_by_id(params[:id])
    @cca = @picture.cca
    
    if params[:taglist].blank?
    
      @picture.errors.add("","You have not specified any tags.")
      render :action => "show"
      return
    
    else
      
      tags = params[:taglist].split(",").collect{ |tag| tag.strip }
      if tags.length < 3
        @picture.errors.add("","You have to specify at least 3 tags.")
        render :action => "show"
        return
      end
      
      # loop through the tags specified...
      tags.each do |t|
        # update the normalized tag...
        normalized_tag = NormalizedTag.find_by_tag(t.downcase)
        normalized_tag = NormalizedTag.create({:tag => normalized_tag, :tag_count=>0}) unless normalized_tag
        normalized_tag.update_attributes(:tag_count => (normalized_tag.tag_count+1))
        
        # update the tag...
        tag = Tag.find_by_tag(t)
        tag = Tag.create({ :tag => t, :normalized_tag_id => normalized_tag.id, :tag_count=>0 }) unless tag
        tag.update_attributes(:tag_count => (tag.tag_count+1))
        
        # link the tag to the picture...
        taggings = Tagging.create({:taggable_type => 'Picture', :taggable_id => @picture.id, :tag_id => tag.id, :normalized_tag_id => normalized_tag.id})
        
        # save the answer...
        turk_answer = TurkAnswer.create({:turkable_type => 'Picture', :turkable_id => @picture.id, :user_id => current_user.id, :cca_id => @cca.id})
        
        redirect_to check_for_cca_turk_for_pictures
        return
      end 
    end
  end
  
end
