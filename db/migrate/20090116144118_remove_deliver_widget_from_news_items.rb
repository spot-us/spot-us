class RemoveDeliverWidgetFromNewsItems < ActiveRecord::Migration
  def self.up
    remove_column :news_items, :deliver_widget
  end

  def self.down
    add_column :news_items, :deliver_widget, :boolean, :default => true
  end
end
