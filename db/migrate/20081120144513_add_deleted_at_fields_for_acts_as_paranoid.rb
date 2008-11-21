class AddDeletedAtFieldsForActsAsParanoid < ActiveRecord::Migration
  def self.up
    add_column  :news_items, :deleted_at, :datetime
    add_column  :pledges, :deleted_at, :datetime
    add_column  :affiliations, :deleted_at, :datetime
    add_column  :users, :deleted_at, :datetime
  end

  def self.down
    remove_column  :news_items, :deleted_at
    remove_column  :pledges, :deleted_at
    remove_column  :affiliations, :deleted_at
    remove_column  :users, :deleted_at
  end
end
