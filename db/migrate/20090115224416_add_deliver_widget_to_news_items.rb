class AddDeliverWidgetToNewsItems < ActiveRecord::Migration
  def self.up
    add_column :news_items, :deliver_widget, :boolean, :default => true
  end

  def self.down
    remove_column :news_items, :deliver_widget
  end
end
