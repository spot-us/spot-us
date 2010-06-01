class AddFactCheckerColumnToAssignment < ActiveRecord::Migration
  def self.up
    add_column :credits, :is_factchecker_assignment, :boolean, :default => false
  end

  def self.down
    remove_column :credits, :is_factchecker_assignment, :boolean, :default => false
  end
end
