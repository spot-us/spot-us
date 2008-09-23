class ChangeKeywordToStringOnNewsItem < ActiveRecord::Migration
  def self.up
    change_column :news_items, :keywords, :string
  end

  def self.down
    change_column :news_items, :keywords, :text
  end
end
