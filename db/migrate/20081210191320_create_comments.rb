class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :title, :commentable_type
      t.integer :commentable_id
      t.belongs_to :user
      t.text :body
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
