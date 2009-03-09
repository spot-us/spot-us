class AddExternalLinksToNewsItems < ActiveRecord::Migration
  def self.up
    add_column :news_items, :external_links, :text
  end

  def self.down
    remove_column :news_items, :external_links
  end
end
