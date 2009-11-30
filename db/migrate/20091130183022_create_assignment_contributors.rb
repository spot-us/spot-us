class CreateAssignmentContributors < ActiveRecord::Migration
  def self.up
    create_table :assignment_contributors do |t|
      t.integer :assignment_id
      t.integer :contributor_id
      t.string :status, :default => "pending"
      t.timestamps
    end
  end

  def self.down
    drop_table :assignment_contributors
  end
end
