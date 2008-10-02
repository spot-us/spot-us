class ChangeVideoEmbedToTextFromString < ActiveRecord::Migration
  def self.up
    change_column(:news_items, :video_embed, :text)
  end

  def self.down
    change_column(:news_items, :video_embed, :string, :limit => 600)
  end
end
