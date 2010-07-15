class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.integer  "parent_id"
		  t.string   "content_type"
		  t.string   "filename", :limit=>80
		  t.string   "thumbnail", :limit=>20
		  t.integer  "size"
		  t.integer  "width"
		  t.integer  "height"
		  t.string   "type", :limit=>40
		  t.integer  "user_id"
		  t.integer  "assetable_id"
		  t.string   "assetable_type", :limit=>40
		  
      t.timestamps
    end
    
    add_index "assets", ["assetable_id", "assetable_type", "type"], :name => "ndx_type_assetable"
		add_index "assets", ["assetable_id", "assetable_type"], :name => "fk_assets"
		add_index "assets", ["parent_id", "type"], :name => "ndx_type_name"
		add_index "assets", ["thumbnail", "parent_id"], :name => "assets_thumbnail_parent_id"
		add_index "assets", ["user_id", "assetable_type", "assetable_id"], :name => "assets_user_type_assetable_id"
		add_index :assets, :user_id, :name=>"fk_user"
  end

  def self.down
    drop_table :assets
  end
end
