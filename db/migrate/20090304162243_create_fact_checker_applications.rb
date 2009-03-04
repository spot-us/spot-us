class CreateFactCheckerApplications < ActiveRecord::Migration
  def self.up
    create_table :fact_checker_applications do |t|
      t.integer :user_id
      t.integer :pitch_id

      t.timestamps
    end
  end

  def self.down
    drop_table :fact_checker_applications
  end
end
