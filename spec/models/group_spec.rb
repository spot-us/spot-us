require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do
  requires_presence_of Group, :name
  requires_presence_of Group, :description

  it { Group.should have_many(:donations) }

  it "should have an image attachment" do
    Factory(:group).image.should be_instance_of(Paperclip::Attachment)
  end

  describe "donations_for_pitch" do
    before do
      @group = Factory(:group)
      @pitch = active_pitch
      Factory(:donation, :group => @group, :pitch => @pitch, :amount => 10)
      Factory(:donation, :group => @group, :pitch => @pitch, :amount => 30)
      Factory(:donation, :group => @group, :amount => 90)
      Factory(:donation, :group => Factory(:group), :pitch => @pitch, :amount => 120)
    end
    it "should return the sum of donations for a pitch" do
      @group.donations_for_pitch(@pitch).should == 40
    end
  end

  describe "donors" do
    before do
      @group = Factory(:group)
      @user1 = Factory(:citizen)
      @user2 = Factory(:citizen)
      Factory(:donation, :user => @user1, :group => @group, :status => 'paid')
      Factory(:donation, :user => @user1, :group => @group, :status => 'paid')
    end
    it "should return those users who have made donations for this group" do
      @group.donors.size.should == 1
    end
    it "should not include users who have not given for this group" do
      @group.donors.should_not include(@user2)
    end
    it "should return a unique set of donors" do
      @group.donors.should == [@user1]
    end
  end

  describe "total_donations" do
    before do
      @group = Factory(:group)
      Factory(:donation, :amount => 10, :group => @group, :status => 'paid')
      Factory(:donation, :amount => 10, :group => @group, :status => 'paid')
    end
    it 'returns the sum of donations for the group' do
      @group.total_donations.should == BigDecimal("20")
    end
    it 'returns 0 if no donations made for the group' do
      Factory(:group).total_donations.should == BigDecimal("0")
    end
  end

  describe "amount_donated_by(user)" do
    before do
      @group = Factory(:group)
      @user1 = Factory(:citizen)
      @user2 = Factory(:citizen)
      @donation = Factory(:donation, :group => @group, :user => @user1, :status => 'paid')
    end
    it "returns the amount a user donated" do
      @group.amount_donated_by(@user1).should == @donation.amount
    end
    it "returns 0 if the user hasn't donated on behalf of the group" do
      @group.amount_donated_by(@user2).should == BigDecimal("0")
    end
  end

  describe "pitches" do
    before do
      @group = Factory(:group)
      @pitch1 = active_pitch
      @pitch2 = active_pitch
      Factory(:donation, :group => @group, :pitch => @pitch1)
      Factory(:donation, :group => @group, :pitch => @pitch1)
    end
    it "should return pitches that are associated with this groups donations" do
      @group.pitches.should include(@pitch1)
    end
    it "should not return other pitches" do
      @group.pitches.should_not include(@pitch2)
    end
    it "should return a unique set of pitches" do
      @group.pitches.should == [@pitch1]
    end
  end

end
