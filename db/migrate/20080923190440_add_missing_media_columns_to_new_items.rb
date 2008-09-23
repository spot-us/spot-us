class AddMissingMediaColumnsToNewItems < ActiveRecord::Migration
  def self.up
    change_table :news_items do |t|
      t.string :video_embed, :featured_image_caption
    end
  end

  def self.down
    change_table :news_items do |t|
      t.remove :video_embed, :featured_image_caption
    end
  end
end
