class PostsController < ApplicationController
  resources_controller_for :post
  before_filter :login_required, :except => [:show, :index]
  before_filter :select_tab
  
  def show
    @post = find_resource
    @pitch = @post.pitch
    if params[:old]
      redirect_to "#{pitch_post_path(@pitch, @post)}", :status => :moved_permanently 
      return
    end
  end

  response_for :create do |format|
    format.html do
      if resource_saved?
        @post.blog_posted_notification
        set_social_notifier_cookie("post")
        flash[:success] = 'Successfully created post'
        redirect_to pitch_post_path(@post.pitch, @post)
      else
        flash[:error] = 'There was an error saving your post'
        render :action => 'new'
      end
    end
  end

  response_for :update do |format|
    format.html do
      if resource_saved?
        flash[:success] = 'Successfully updated post'
        redirect_to pitch_post_path(@post.pitch, @post)
      else
        flash[:error] = 'There was an error updating your post'
        render :action => 'edit'
      end
    end
  end

  response_for :destroy do |format|
    format.html do
      redirect_to myspot_posts_path
    end
  end

  private

  def new_resource
    returning resource_service.new(params[resource_name]) do |resource|
      resource.user = current_user
    end
  end

  def authorized?
    current_user && enclosing_resource.postable_by?(current_user)
  end
  
  def select_tab
    @tab = "updates"
  end
    
end
