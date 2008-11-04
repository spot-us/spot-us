class UserAddFactCheckerId < ActiveRecord::Migration
  def self.up
    add_column :news_items, :fact_checker_id, :integer
  end

  def self.down
    remove_column :news_items, :fact_checker_id
  end
end
