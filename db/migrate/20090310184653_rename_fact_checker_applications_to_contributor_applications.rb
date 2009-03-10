class RenameFactCheckerApplicationsToContributorApplications < ActiveRecord::Migration
  def self.up
    rename_table :fact_checker_applications, :contributor_applications
  end

  def self.down
    rename_table :contributor_applications, :fact_checker_applications
  end
end
