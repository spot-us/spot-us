class ModyfyingFieldInAsyncPosts < ActiveRecord::Migration
  def self.up
    rename_column :async_posts, :type, :post_type
  end

  def self.down
    rename_column :async_posts, :post_type, :type
  end
end
