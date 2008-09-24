class AddUserIdToNewsItems < ActiveRecord::Migration
  def self.up
    add_column :news_items, :user_id, :integer
    add_index :news_items, :user_id
  end

  def self.down
    remove_index :news_items, :user_id
    remove_column :news_items, :user_id
  end
end
