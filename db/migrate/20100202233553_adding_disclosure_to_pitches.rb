class AddingDisclosureToPitches < ActiveRecord::Migration
  def self.up
    add_column :news_items, :disclosure, :text
  end

  def self.down
    remove_column :news_items, :disclosure
  end
end
