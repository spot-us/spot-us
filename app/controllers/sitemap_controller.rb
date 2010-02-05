class SitemapController < ApplicationController
  
  def index
    sitemap_types = {'posts'=>true, 'stories'=>true, 'pitches'=>true}
    unless sitemap_types[params[:type]]
      #redirect to landing page or better present 404
      redirect_to '/'
    end 
    
    @type = params[:type]
    case @type
      when 'posts'
        @posts = Post.find(:all)
      when 'stories'
        @stories = Story.published.find(:all)
      when 'pitches'
        @pitches = Pitch.browsable.find(:all)
    end
    
    render :layout=>false
    
  end
  
  def sitemap_index
  end
  
end
