class AddNotifyCommentsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_comments, :boolean, :default => false, :after => :notify_blog_posts
    User.update_all("notify_comments = 1")
  end

  def self.down
    remove_column :users, :notify_comments
  end
end
