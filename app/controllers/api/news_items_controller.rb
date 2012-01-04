class Api::NewsItemsController < ApplicationController

  def geography
    
    get_items(10)
    pitches = []
    
    @news_items.each do |news_item|
    
      # main pitch details
      arr = ActiveSupport::OrderedHash.new
      arr[:id] = pitch.id
      arr[:headline] = pitch.headline
      arr[:permalink] = pitch.permalink
      arr[:status] = pitch.status
      arr[:created_at] = pitch.created_at
      arr[:updated_at] = pitch.updated_at
      arr[:expiration_date] = pitch.expiration_date
      arr[:is_funded] = pitch.fully_funded?
      arr[:thumb_url] = pitch.featured_image(:small_hero) 
      arr[:description] = pitch.short_description.strip_and_shorten_character_limit(80)
      arr[:currency] = "credits"

      # author
      author = ActiveSupport::OrderedHash.new
      author[:full_name] = pitch.user.full_name
      author[:profile_url] = pitch.user.permalink
      arr[:author] = author

      # progress
      progress = ActiveSupport::OrderedHash.new
      progress[:raised_amount] = pitch.current_funding
      progress[:funding_in_percentage] = pitch.funding_in_percentage
      progress[:funding_needed] = pitch.funding_needed
      progress[:requested_amount] = pitch.requested_amount
      arr[:progress] = progress
      
      arr[:geographies] = Entity.geographies?(p.short_description)
      arr[:coordinates] = Entity.coordinates?(p.short_description)
    
      pitches << arr
    end
    
    render :json => pitches
    
  end

  protected
  
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
