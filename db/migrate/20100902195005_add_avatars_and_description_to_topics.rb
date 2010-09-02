class AddAvatarsAndDescriptionToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :featured_image_file_name, :string
    add_column :topics, :featured_image_content_type, :string
    add_column :topics, :featured_image_file_size, :integer
    add_column :topics, :featured_image_updated_at, :datetime
    add_column :topics, :description, :text
  end

  def self.down
    remove_column :topics, :featured_image_file_name
    remove_column :topics, :featured_image_content_type
    remove_column :topics, :featured_image_file_size
    remove_column :topics, :featured_image_updated_at
    remove_column :topics, :description
  end
end
