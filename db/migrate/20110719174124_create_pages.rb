class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string    "title"
      t.string    "slug"
      t.text      "excerpt"
      t.text      "body"
      t.text      "embed_code"
      t.string    "featured_image_file_name"
      t.string    "featured_image_content_type"
      t.integer   "featured_image_file_size"
      t.datetime  "featured_image_updated_at"
      t.integer   "status",                      :limit => 2, :default => 0
      t.integer   "viewed",                                   :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
