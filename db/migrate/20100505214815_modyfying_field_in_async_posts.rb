class ModyfyingFieldInAsyncPosts < ActiveRecord::Migration
  def self.up
    rename_column :users, :type, :post_type
  end

  def self.down
    rename_column :users, :post_type, :type
  end
end
