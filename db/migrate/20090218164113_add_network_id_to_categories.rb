class AddNetworkIdToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :network_id, :integer
  end

  def self.down
    remove_column :categories, :network_id
  end
end
