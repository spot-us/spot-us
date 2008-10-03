class AddStatusFieldToPitches < ActiveRecord::Migration
  def self.up
    add_column :news_items, :status, :string, :default => "active"
  end

  def self.down
     remove_column :news_items, :status
  end
end
