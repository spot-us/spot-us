class SitemapController < ApplicationController
  
  def index
    sitemap_types = {'posts'=>true}
    unless sitemap_types[params[:type]]
      #redirect to landing page or better present 404
    end 
    
    @type = params[:type]
    
    case @type
      when 'posts'
        @posts = Post.find(:all)
    end
    
    render :layout=>false
    
  end
  
  def sitemap_index
  end
  
end
