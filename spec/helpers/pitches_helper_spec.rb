require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PitchesHelper do
  include PitchesHelper

  describe "#citizen_supporters_for" do
    before do
      @organization = Factory(:organization)
      @citizen = Factory(:citizen)
      @pitch = active_pitch(:requested_amount => 1000)
      Factory(:donation, :pitch => @pitch, :user => @citizen, :amount => 10)
      Factory(:donation, :pitch => @pitch, :user => @organization, :amount => 100)
    end
    it "should include all citizen donors" do
      citizen_supporters_for(@pitch).should include(@citizen)
    end
    it "should exclude all organization donors" do
      citizen_supporters_for(@pitch).should_not include(@organization)
    end
  end
end
