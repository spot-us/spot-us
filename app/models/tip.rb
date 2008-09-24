class Tip < NewsItem
  attr_accessor :pledge_amount

  has_many :pledges
  has_many :supporters, :through => :pledges, :source => :user, :order => "pledges.created_at"

  before_create :build_initial_pledge
 
  validates_presence_of :short_description
  validates_presence_of :keywords
  validates_presence_of :user
  validates_presence_of :pledge_amount, :on => :create

  validates_inclusion_of :location, :in => LOCATIONS

  def total_amount_pledged
    pledges.sum(:amount_in_cents).to_dollars
  end

  private

  def build_initial_pledge
    pledges.build(:user_id => user_id, :amount => pledge_amount)
  end
end
