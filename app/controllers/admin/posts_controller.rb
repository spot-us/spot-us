class Admin::PostsController < ApplicationController
  resources_controller_for :posts
  before_filter :admin_required
  layout 'bare'
  
  def index
    @posts = Post.paginate(:page => params[:page], :per_page => 40, :order => "created_at desc")
  end

  response_for :create do |format|
    format.html do
      if resource_saved?
        flash[:success] = "Success!"
        redirect_to admin_posts_path
      else
        render :action => 'new'
      end
    end
  end

  response_for :update do |format|
    format.html do
      if resource_saved?
        flash[:success] = "Success!"
        redirect_to admin_posts_path
      else
        render :action => 'edit'
      end
    end
  end

end
