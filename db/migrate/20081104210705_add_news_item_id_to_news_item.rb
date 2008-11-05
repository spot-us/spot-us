class AddNewsItemIdToNewsItem < ActiveRecord::Migration
  def self.up
    add_column :news_items, :news_item_id, :integer
  end

  def self.down
    drop_column :news_items, :news_item_id
  end
end
