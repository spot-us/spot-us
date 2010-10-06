class AddBannerToCcas < ActiveRecord::Migration
  def self.up
    add_column :ccas, :banner_file_name, :string
    add_column :ccas, :banner_content_type, :string
    add_column :ccas, :banner_file_size, :integer
    add_column :ccas, :banner_updated_at, :datetime
  end

  def self.down
    remove_column :ccas, :banner_file_name
    remove_column :ccas, :banner_content_type
    remove_column :ccas, :banner_file_size
    remove_column :ccas, :banner_updated_at
  end
end
