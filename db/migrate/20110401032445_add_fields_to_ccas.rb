class AddFieldsToCcas < ActiveRecord::Migration
  def self.up
    add_column :ccas, :total_turks, :integer
    add_column :ccas, :maximum_turks_per_user, :integer
    add_column :ccas, :minimum_turks_per_user, :integer
  end

  def self.down
    remove_column :ccas, :total_turks
    remove_column :ccas, :maximum_turks_per_user
    remove_column :ccas, :minimum_turks_per_user
  end
end
