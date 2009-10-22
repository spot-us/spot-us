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
    include AASMWithFixes
    belongs_to :user
    belongs_to :pitch
    
    validates_presence_of :user_id, :pitch_id, :amount
    validates_numericality_of :amount, :greater_than => 0
    validate_on_create :check_donation, :if => lambda { |me| me.pitch }
    validate_on_update :disable_updating_paid_donations, :check_donation, :if => lambda { |me| me.pitch }
    named_scope :unpaid, :conditions => "status = 'unpaid'"
    named_scope :paid, :conditions => "status = 'paid'"
    
    aasm_column :status
    aasm_initial_state  :unpaid

    aasm_state :unpaid
    aasm_state :paid

    aasm_event :pay do
      transitions :from => :unpaid, :to => :paid 
    end
    
    def self.createable_by?(user)
      user
    end
    
    def update_pitch_funding
      if pitch.requested_amount < pitch.current_funding + amount
            amount = pitch.request_amount - pitch.current_funding
            pitch.current_funding = pitch.request_amount
      else
          pitch.current_funding += amount
      end
      pitch.save
    end
    
    protected
    
    def check_donation
      if pitch.fully_funded?
        errors.add_to_base("Great news! This pitch is already fully funded therefore it can't be donated to any longer.")
        return
      end
    end
    
    def disable_updating_paid_donations
      if paid? && !being_marked_as_paid?
        errors.add_to_base('Paid donations cannot be updated')
      end
    end

    def being_marked_as_paid?
      status_changed? && status_was == 'unpaid'
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