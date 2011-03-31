class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.string      :image_id	
      t.integer     :year	
      t.string      :poy	
      t.string      :division	
      t.integer     :category	
      t.string      :award	
      t.string      :first_name	
      t.string      :last_name	
      t.string      :organization	
      t.string      :location	
      t.string      :title	
      t.text        :caption	
      t.string      :gender	
      t.string      :color	
      t.string      :old_keywords
      t.string      :keywords
      t.string      :assigned_category	
      t.string      :number_of_pictures	
      t.string      :number_in_series	
      t.string      :proof
      t.integer     :cca_id
      t.string      :photo_file_name
      t.string      :photo_content_type
      t.integer     :photo_file_size
      t.datetime    :photo_updated_at
      t.timestamps
    end
    
    add_column :ccas, :is_picture_task, :boolean, :default => false
  end

  def self.down
    drop_table :pictures
    remove_column :ccas, :is_picture_task
  end
end
