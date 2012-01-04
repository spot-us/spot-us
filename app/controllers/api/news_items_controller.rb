class Api::NewsItemsController < ApplicationController

  def entities
    
    get_items(10)
    news_items = []
    
    @news_items.each do |news_item|
      arr = get_news_item_arr(news_item)
      arr[:entities] = entity.entities?
      
      news_items << arr
    end
    
    render :json => news_items
    
  end

  def geography
    
    get_items(10)
    news_items = []
    
    @news_items.each do |news_item|
      arr = get_news_item_arr(news_item)
      arr[:coordinates] = entity.coordinates?
      
      news_items << arr
    end
    
    render :json => news_items
    
  end

  def kml
    get_items(10)
  end

  protected
  
  def get_news_item_arr(news_item)
    # main news_item details
    arr = ActiveSupport::OrderedHash.new
    arr[:id] = news_item.id
    arr[:headline] = news_item.headline
    arr[:permalink] = news_item.permalink
    arr[:status] = news_item.status
    arr[:created_at] = news_item.created_at
    arr[:updated_at] = news_item.updated_at
    arr[:expiration_date] = news_item.expiration_date
    arr[:is_funded] = news_item.fully_funded?
    arr[:thumb_url] = news_item.featured_image(:small_hero) 
    arr[:description] = news_item.short_description.strip_and_shorten_character_limit(80)
    arr[:currency] = "credits"

    # author
    author = ActiveSupport::OrderedHash.new
    author[:full_name] = news_item.user.full_name
    author[:profile_url] = news_item.user.permalink
    arr[:author] = author

    # progress
    progress = ActiveSupport::OrderedHash.new
    progress[:raised_amount] = news_item.current_funding
    progress[:funding_in_percentage] = news_item.funding_in_percentage
    progress[:funding_needed] = news_item.funding_needed
    progress[:requested_amount] = news_item.requested_amount
    arr[:progress] = progress
    
    # create the entity if it does not exist.
    entity = Entity.find(:first, :conditions => ["entitable_id=? and entitable_type=?", news_item.id, news_item.class.to_s])
    entity = Entity.create(:entitable_id => news_item.id, :entitable_type => news_item.class.to_s) unless entity
    
    # if the news item has an entity associated...
    if entity.request_body.blank?
      entity.process?(news_item.headline + " " + news_item.short_description) 
      sleep 1
    end
  end
  
  
  def get_items(limit=nil)
    @requested_page = params[:page] || 1                                          # allow pagination
    @topic_id = params[:topic_id] || -1                                           # for simplicity for the API
    @grouping_id = params[:grouping_id] || -1                                     # for simplicity for the API
    @channels = Channel.by_network(current_network)                               # get the channels
    @network = current_network                                                    # get the network
    @topic = params[:topic] ? Topic.find_by_seo_name(params[:topic]) : nil        # get the topic
    @filter = params[:filter] ? params[:filter] : 'unfunded'                      # get the filter
    @filter = "updates" if @filter=='posts'
    @full = params[:length]
    
    unless @filter=='updates'
      @news_items = NewsItem.get_stories(@requested_page, @topic_id, @grouping_id, @topic, @filter, current_network, limit) 
    else
      @news_items = Post.by_network(@current_network).paginate(:page => params[:page], :order => "posts.id desc", :per_page=>9)
    end
  end

end
