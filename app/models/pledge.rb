# == Schema Information
# Schema version: 20090218144012
#
# Table name: pledges
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  tip_id     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#  amount     :decimal(15, 2)
#

class Pledge < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 10

  acts_as_paranoid
  belongs_to :user
  belongs_to :tip
  validates_presence_of :tip_id
  validates_presence_of :user_id
  validates_presence_of :amount
  validates_numericality_of :amount, :greater_than => 0, :allow_blank => true
  validates_uniqueness_of :tip_id, :scope => [:user_id, :deleted_at]

  def self.createable_by?(user)
    !user.nil?
  end

  def editable_by?(user)
    self.user == user
  end
end


