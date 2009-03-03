class CreateOrganizationPitches < ActiveRecord::Migration
  def self.up
    create_table :organization_pitches do |t|
      t.integer :organization_id
      t.integer :pitch_id

      t.timestamps
    end
  end

  def self.down
    drop_table :organization_pitches
  end
end
