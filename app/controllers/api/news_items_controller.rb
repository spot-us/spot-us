class Api::NewsItemsController < ApplicationController

  def entities
    get_items
    news_items = []
    @news_items.each { |news_item| news_items << get_news_item_arr(news_item, "entities") }
    render :json => news_items
  end

  def geography
    get_items
    news_items = []
    @news_items.each { |news_item| news_items << get_news_item_arr(news_item, "coordinates") }
    render :json => news_items
  end

  def kml
    get_items
    @items = []
    @news_items.each { |news_item| @items << get_news_item_arr(news_item, "coordinates") }
    
    # handle the different formats supported
    respond_to do |format|
      format.xml do
        render :layout => false
      end
    end
  end

  protected
  
  def get_news_item_arr(news_item, entity_type="coordinates")
    # main news_item details
    arr = ActiveSupport::OrderedHash.new
    arr[:id] = news_item.id
    arr[:slug] = news_item.slug
    arr[:headline] = news_item.headline
    arr[:permalink] = news_item.permalink
    arr[:status] = news_item.status
    arr[:created_at] = news_item.created_at
    arr[:updated_at] = news_item.updated_at
    arr[:expiration_date] = news_item.expiration_date
    arr[:is_funded] = news_item.is_a?(Story) ? true : news_item.fully_funded?
    arr[:thumb_url] = news_item.featured_image(:small_hero) 
    arr[:description] = news_item.short_description.strip_and_shorten_character_limit(80) if news_item.short_description
    arr[:description] = news_item.extended_description.strip_and_shorten_character_limit(80) if news_item.extended_description
    arr[:currency] = "credits"

    # author
    author = ActiveSupport::OrderedHash.new
    author[:full_name] = news_item.user.full_name
    author[:profile_url] = news_item.user.permalink
    author[:thumb_url] = news_item.user.photo.url(:thumb)
    arr[:author] = author

    # progress
    unless news_item.is_a?(Story)
      progress = ActiveSupport::OrderedHash.new
      progress[:raised_amount] = pitch.funding_needed>0 ? pitch.current_funding : pitch.requested_amount
      progress[:funding_in_percentage] = pitch.funding_needed>0 ? pitch.funding_in_percentage : 100
      progress[:funding_needed] = pitch.funding_needed>0 ? pitch.funding_needed : 0
      progress[:requested_amount] = pitch.funding_needed>0 ? pitch.current_funding : pitch.requested_amount
      arr[:progress] = progress
    end
    
    # create the entity if it does not exist.
    entity = Entity.find(:first, :conditions => ["entitable_id=? and entitable_type=?", news_item.id, news_item.class.to_s])
    entity = Entity.create(:entitable_id => news_item.id, :entitable_type => news_item.class.to_s) unless entity
    
    # if the news item has an entity associated...
    if entity.request_body.blank?
      entity.process?(news_item.headline + " " + news_item.short_description) if news_item.short_description
      entity.process?(news_item.headline + " " + news_item.extended_description) if news_item.extended_description
      sleep 1
    end
    
    arr[:coordinates] = entity.coordinates? if entity_type == "coordinates"
    arr[:entities] = entity.entities? if entity_type == "entities"
    arr
  end
  
  
  def get_items
    @requested_page = params[:page] || 1                                          # allow pagination
    @topic_id = params[:topic_id] || -1                                           # for simplicity for the API
    @grouping_id = params[:grouping_id] || -1                                     # for simplicity for the API
    @channels = Channel.by_network(current_network)                               # get the channels
    @network = current_network                                                    # get the network
    @topic = params[:topic] ? Topic.find_by_seo_name(params[:topic]) : nil        # get the topic
    @filter = params[:filter] ? params[:filter] : 'unfunded'                      # get the filter
    per_page = params[:per_page] || 10
    limit = params[:limit]
    
    NewsItem.per_page = per_page
    @news_items = NewsItem.get_stories(@requested_page, @topic_id, @grouping_id, @topic, @filter, current_network, limit) 
  end

end
