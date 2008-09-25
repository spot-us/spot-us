class CreateAffiliations < ActiveRecord::Migration
  def self.up
    create_table :affiliations do |t|
      t.belongs_to :tip
      t.belongs_to :pitch
      t.timestamps
    end
    add_index :affiliations, :tip_id
    add_index :affiliations, :pitch_id
  end

  def self.down
    remove_index :affiliations, :column => :pitch_id
    remove_index :affiliations, :column => :tip_id
    drop_table :affiliations
  end
end
