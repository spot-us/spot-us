class AddLicenseToNewsItems < ActiveRecord::Migration
  def self.up
    add_column :news_items, :license, :text
  end

  def self.down
    remove_column :news_items, :license
  end
end
