# == Schema Information
# Schema version: 20091012191325
#
# Table name: credit_pitches

# t.integer  "user_id"
# t.integer  "pitch_id"
# t.decimal  "amount",     :precision => 15, :scale => 2
# t.datetime "created_at"
# t.datetime "updated_at"

class CreditPitch < ActiveRecord::Base
    belongs_to :user
    belongs_to :pitch
    
    validates_presence_of :user_id, :pitch_id, :amount
    validates_numericality_of :amount, :greater_than => 0    
    
    def self.createable_by?(user)
      user
    end
    
    def self.has_enough_credits?(credit_pitch_amounts, user)
        credit_total = 0
        credit_pitch_amounts.values.each do |val|
          credit_total += val["amount"].to_f
        end
        return true if credit_total <= user.total_credits
        return false
    end
end