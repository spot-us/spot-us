class CreateIncentives < ActiveRecord::Migration
  def self.up
    create_table :incentives do |t|
      t.integer       :incentive_id, :pitch_id
      t.string        :description
      t.timestamps
    end
  end

  def self.down
    drop_table :incentives
  end
end
