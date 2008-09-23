class RenameFieldsOnPitch < ActiveRecord::Migration
  def self.up
    change_table :pitches do |t|
      t.rename :extened_desciption, :extended_description
      t.rename :video_delivery, :deliver_video
      t.rename :audio_delivery, :deliver_audio
      t.rename :text_delivery,  :deliver_text
      t.rename :photo_delivery, :deliver_photo
    end
  end

  def self.down
    change_table :pitches do |t|
      t.rename :extended_description, :extened_desciption
      t.rename :deliver_video,        :video_delivery
      t.rename :deliver_audio,        :audio_delivery
      t.rename :deliver_text,         :text_delivery
      t.rename :deliver_photo,        :photo_delivery
    end 
  end
end
