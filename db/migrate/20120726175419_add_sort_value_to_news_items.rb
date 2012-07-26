class AddSortValueToNewsItems < ActiveRecord::Migration
  def self.up
    add_column :news_items, :sort_value, :float
    NewsItem.reset_column_information
    NewsItem.update_all("sort_value=(1.0 - (current_funding / requested_amount))")
  end

  def self.down
    remove_column :news_items, :sort_value
  end
end
