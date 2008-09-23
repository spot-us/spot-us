class CreatePitch < ActiveRecord::Migration
  def self.up
    create_table :pitches do |t|
      t.string :headline, :location, :requested_amount, :state
      t.text :short_description, :delivery_description, :extened_desciption, :skills, :keywords
      t.boolean :text_delivery, :audio_delivery, :video_delivery, :photo_delivery, :contract_agreement
      t.datetime :expiration_date
      t.timestamps
    end
    add_index :pitches, :state
    add_index :pitches, :location
    add_index :pitches, :expiration_date
  end

  def self.down
    drop_table :pitches
  end
end
