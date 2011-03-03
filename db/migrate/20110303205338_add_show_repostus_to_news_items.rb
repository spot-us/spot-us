class AddShowRepostusToNewsItems < ActiveRecord::Migration
  def self.up
    add_column :news_items, :show_repostus, :boolean
  end

  def self.down
    remove_column :news_items, :show_repostus
  end
end
