class HomesController < ApplicationController
  
  def show
    get_items
  end

  def start_story
    if !logged_in?
      session[:return_to] = start_story_path
      redirect_to new_session_path
    elsif logged_in? && current_user.is_a?(Reporter) || current_user.is_a?(Organization)
      redirect_to new_pitch_path
    else
      redirect_to new_tip_path
    end
  end
  
  protected

  def get_items(limit=nil)
    @requested_page = params[:page] || 1                                          # allow pagination
    @topic_id = params[:topic_id] || -1                                           # for simplicity for the API
    @grouping_id = params[:grouping_id] || -1                                     # for simplicity for the API
    @channels = Channel.by_network(current_network)                               # get the channels
    @network = current_network                                                    # get the network
    @topic = params[:topic] ? Topic.find_by_seo_name(params[:topic]) : nil        # get the topic
    @filter = params[:filter] ? params[:filter] : 'featured'                      # get the filter
    NewsItem.per_page = 9
    @items = NewsItem.get_stories(@requested_page, @topic_id, @grouping_id, @topic, @filter, current_network, limit) if @filter!='updates' && @filter!='community'
    @items = Post.by_network(@current_network).paginate(:page => params[:page], :order => "posts.id desc", :per_page=>9) if @filter=='updates'
    if @filter=='community'
      user_ids_all = Donation.paid.by_network(current_network).find(:all, :group=>"donations.user_id").map(&:user_id).join(',')
      @items = Donation.by_network(current_network).paginate(:page => params[:page], :select=>"donations.*, max(donations.id) as max_id", 
        :conditions=>"donations.user_id in (#{user_ids_all})", :group=>"donations.user_id", :order=>'max_id desc', :per_page => 9)
    end
  end
  
end
