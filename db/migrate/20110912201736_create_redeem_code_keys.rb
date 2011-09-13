class CreateRedeemCodeKeys < ActiveRecord::Migration
  def self.up
    create_table :redeem_code_keys do |t|
      t.string        :code
      t.float         :amount
      t.text          :description
      t.integer       :cap
      t.timestamps
    end
    add_column :credits, :redeem_code_key_id, :integer
  end

  def self.down
    drop_table :redeem_code_keys
    remove_column :credits, :redeem_code_key_id
  end
end
