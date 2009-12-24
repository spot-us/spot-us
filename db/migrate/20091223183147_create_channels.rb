class CreateChannels < ActiveRecord::Migration
  def self.up
     create_table :channels do |t|
       t.string :title
       t.string :channel_image_file_name
       t.string :status
       t.string :description
       t.timestamps
     end
   end

   def self.down
     drop_table :channels
   end
end

