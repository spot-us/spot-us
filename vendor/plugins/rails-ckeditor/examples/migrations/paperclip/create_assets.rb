class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string  :data_file_name
      t.string  :data_content_type
      t.integer :data_file_size
      
      t.integer :assetable_id
		  t.string  :assetable_type, :limit=>25
      t.string  :type, :limit=>25
		  
		  t.integer :user_id
		  
      t.timestamps
    end
    
    add_index "assets", ["assetable_id", "assetable_type", "type"], :name => "ndx_type_assetable"
		add_index "assets", ["assetable_id", "assetable_type"], :name => "fk_assets"
		add_index "assets", ["user_id"], :name => "fk_user"
  end

  def self.down
    drop_table :assets
  end
end
