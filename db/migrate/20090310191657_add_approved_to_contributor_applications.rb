class AddApprovedToContributorApplications < ActiveRecord::Migration
  def self.up
    add_column :contributor_applications, :approved, :boolean, :default => false
  end

  def self.down
    remove_column :contributor_applications, :approved
  end
end
