class AddWidgetEmbedToNewsItems < ActiveRecord::Migration
  def self.up
    add_column :news_items, :widget_embed, :text
  end

  def self.down
    remove_column :news_items, :widget_embed
  end
end
