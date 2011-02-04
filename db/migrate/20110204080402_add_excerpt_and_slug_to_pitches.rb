class AddExcerptAndSlugToPitches < ActiveRecord::Migration
  def self.up
    add_column :news_items, :slug, :string
    add_column :news_items, :excerpt, :text 
  end

  def self.down
    drop_column :news_items, :slug
    drop_column :news_items, :excerpt
  end
end
