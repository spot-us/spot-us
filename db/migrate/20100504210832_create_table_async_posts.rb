class CreateTableAsyncPosts < ActiveRecord::Migration
  def self.up
     create_table :async_posts do |t|
       t.integer :user_id
       t.string :type, :message, :title, :description, :link, :picture
       t.integer :status, :limit => 1, :default => 0
       t.timestamps
     end
  end

  def self.down
    drop_table :async_posts
  end
end
