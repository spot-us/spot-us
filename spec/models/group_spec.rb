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
      @pitch = Factory(:pitch)
      Factory(:donation, :group => @group, :pitch => @pitch, :amount => 10)
      Factory(:donation, :group => @group, :pitch => @pitch, :amount => 30)
      Factory(:donation, :group => @group, :pitch => Factory(:pitch), :amount => 90)
      Factory(:donation, :group => Factory(:group), :pitch => @pitch, :amount => 120)
    end
    it "should return the sum of donations for a pitch" do
      @group.donations_for_pitch(@pitch).should == 40
    end
  end

end
