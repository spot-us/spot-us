class AddDefaultValueToNewsItemsCurrentFunding < ActiveRecord::Migration
  def self.up
    change_column_default :news_items, :current_funding, 0.00
    execute "UPDATE news_items SET current_funding = 0.00 WHERE current_funding IS NULL"
  end

  def self.down
    execute "ALTER TABLE news_items ALTER COLUMN current_funding SET DEFAULT NULL"
  end
end
