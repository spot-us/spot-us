class AddFactCheckerColumnToAssignment < ActiveRecord::Migration
  def self.up
    add_column :assignments, :is_factchecker_assignment, :boolean, :default => false
  end

  def self.down
    remove_column :assignments, :is_factchecker_assignment
  end
end
