class AddEmbedCodeToCcas < ActiveRecord::Migration
  def self.up
    add_column :ccas, :embed_code, :text
    add_column :ccas, :length_of_video, :string
  end

  def self.down
    remove_column :ccas, :embed_code
    remove_column :ccas, :length_of_video
  end
end
