class AddFactCheckInterestToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :fact_check_interest, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :users, :fact_check_interest
  end
end
