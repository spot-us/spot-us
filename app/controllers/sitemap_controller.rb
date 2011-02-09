class SitemapController < ApplicationController
  
  def index
    @url_set = {:xmlns=>"http://www.sitemaps.org/schemas/sitemap/0.9"}
    @news ||= params[:news]
    @url_set["xmlns:n".to_sym] = "http://www.google.com/schemas/sitemap-news/0.9" if @news
    @prefix_template = @news ? "news_" : ""
    initialize_sitemap
  end
  
  def sitemap_index
  end
  
  protected

   def initialize_sitemap
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
         @pitches = Pitch.accepted.find(:all)
     end

     render :layout=>false
   end
   
end
