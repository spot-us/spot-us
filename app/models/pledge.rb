class Pledge < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :user
  belongs_to :tip
  validates_presence_of :tip_id
  validates_presence_of :user_id
  validates_presence_of :amount
  validates_uniqueness_of :tip_id, :scope => [:user_id, :deleted_at]

  has_dollar_field :amount

  def self.createable_by?(user)
    !user.nil?
  end

  def editable_by?(user)
    self.user == user
  end
end


# == Schema Information
# Schema version: 20090116200734
#
# Table name: pledges
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  tip_id          :integer(4)
#  amount_in_cents :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#

