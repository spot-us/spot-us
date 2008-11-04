class NewsItemResetStatusDefault < ActiveRecord::Migration
  def self.up
    change_column :news_items, :status, :string, :default => nil
  end

  def self.down   
  end
end
