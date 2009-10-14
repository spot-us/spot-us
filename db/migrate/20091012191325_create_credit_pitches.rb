class CreateCreditPitches < ActiveRecord::Migration
    def self.up
      create_table :credit_pitches do |t|
        t.integer :user_id
        t.integer :pitch_id
        t.decimal :amount, :precision => 15, :scale => 2
        t.timestamps
      end
      add_index :credit_pitches, :user_id
      add_index :credit_pitches, :pitch_id
    end

    def self.down
      drop_table :credit_pitches
    end
end
