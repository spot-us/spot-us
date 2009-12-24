class CreateChannelPitches < ActiveRecord::Migration
  def self.up
     create_table :channel_pitches do |t|
       t.integer :channel_id
       t.integer :pitch_id
       t.timestamps
     end
   end

   def self.down
     drop_table :channel_pitches
   end
end
