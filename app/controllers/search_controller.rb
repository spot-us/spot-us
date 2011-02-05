class SearchController < ApplicationController
  
  def index
    
    if params[:q]
      redirect_to "/search/#{URI.encode(params[:q])}"
      return
    end
    
    @tab = params[:tab] ? params[:tab] : "unfunded"
    @search_term = URI.encode(params[:search_term] || params[:q] || "")
    @page = params[:page] ? params[:page] : 1
    
    conditions = {}
    
    if @tab == "unfunded"
      Pitch.per_page = 9
      @items = Pitch.search @search_term, :order => :created_at, :sort_mode => :desc, :conditions => conditions, :page => @page, :per_page=>9, :retry_stale => true
      @template_name = 'pitches/pitch'
    elsif @tab == "published" 
      Story.per_page = 9
      @items = Story.search @search_term, :order => :created_at, :sort_mode => :desc, :conditions => conditions, :page => @page, :per_page=>9, :retry_stale => true
      @template_name = 'stories/story'
    elsif @tab == "updates" 
      Post.per_page = 9
      @items = Post.search @search_term, :order => :created_at, :sort_mode => :desc, :conditions => conditions, :page => @page, :per_page=>9, :retry_stale => true
      @template_name = 'posts/post'
    elsif @tab == "community" 
      User.per_page = 9
      @items = User.search @search_term, :order => :created_at, :sort_mode => :desc, :conditions => conditions, :page => @page, :per_page=>9, :retry_stale => true
      @template_name = 'users/user'
    else
      Pitch.per_page = 9
      @items = Pitch.search @search_term, :order => :created_at, :sort_mode => :desc, :conditions => conditions, :page => @page, :per_page=>9, :retry_stale => true
      @template_name = 'pitches/pitch'
    end 
  end
  
end
