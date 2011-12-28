class Api::SearchController < ApplicationController

  def index
    
    @filter = params[:filter] ? params[:filter] : "unfunded"
    @page = params[:page] ? params[:page] : 1
    @ids_only = !params[:pass_ids_back].nil?
    @full = !params[:full].nil? 
    @require_nr_matched_terms = params[:nr_matched_terms].to_i || 1
    @terms = params[:terms].split(",").collect { |term| URI.encode(term.strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))  }
    @matched_terms = []
    
    unless @terms 
      @items = nil
    else
      items_found = false
      starting_length = @terms.length
      i = 1
      until items_found || (starting_length - i + 1)  < @require_nr_matched_terms
        @items, items_found = get_items(@page, @filter, get_search_term(@terms,i))
        @matched_terms = search_terms(@terms,i) if items_found
        i += 1
      end
    end
    
    respond_to do |format|
      format.xml do
        render :layout => false
      end
      format.rss do
        render :layout => false
      end
    end

  end
  
  protected
  
  def get_items(page, filter_term, search_term)
    if filter_term == "unfunded"
      conditions = {:status => "'active'"}
      Pitch.per_page = 10
      items = Pitch.search search_term, :order => :created_at, :sort_mode => :desc, :conditions => conditions, :page => page, :per_page => 10, :retry_stale => true
    elsif filter_term == "funded"
      conditions = {:status => "'funded'"}
      Pitch.per_page = 10
      items = Pitch.search search_term, :order => :created_at, :sort_mode => :desc, :conditions => conditions, :page => page, :per_page => 10, :retry_stale => true
    elsif filter_term == "published" 
      conditions = {:status => 'published'}
      Story.per_page = 10
      items = Story.search search_term, :order => :created_at, :sort_mode => :desc, :conditions => conditions, :page => page, :per_page => 10, :retry_stale => true
    else
      conditions = {:status => "'active'"}
      Pitch.per_page = 10
      items = Pitch.search search_term, :order => :created_at, :sort_mode => :desc, :conditions => conditions, :page => page, :per_page => 10, :retry_stale => true
    end
    
    return items, !items.empty?
  end
  
  def search_terms(terms,i)
    terms.slice(0, (terms.length-i)+1)
  end
  
  def get_search_term(terms,i)
    search_terms(terms,i).join(" ")
  end

end
