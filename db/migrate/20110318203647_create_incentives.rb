class CreateIncentives < ActiveRecord::Migration
  def self.up
    create_table :incentives do |t|
      t.integer       :pitch_id
      t.float         :amount
      t.string        :description
      t.timestamps
    end
  end

  def self.down
    drop_table :incentives
  end
end
