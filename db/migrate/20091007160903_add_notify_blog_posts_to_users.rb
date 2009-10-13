class AddNotifyBlogPostsToUsers < ActiveRecord::Migration
  def self.up
      add_column :users, :notify_blog_posts, :boolean, :default => false, :null => false, :after => :country
      User.update_all("notify_blog_posts = 1")
  end

  def self.down
      remove_column :users, :notify_blog_posts
  end
end
