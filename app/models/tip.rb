class Tip < NewsItem
  attr_accessor :pledge_amount_in_cents

  has_many :pledges

  before_save :build_initial_pledge
 
  validates_presence_of :short_description
  validates_presence_of :keywords
  validates_presence_of :user

  validates_inclusion_of :location, :in => LOCATIONS

  private

  def build_initial_pledge
    pledges.build(:user_id => user_id, :amount_in_cents => pledge_amount_in_cents)
  end
end
